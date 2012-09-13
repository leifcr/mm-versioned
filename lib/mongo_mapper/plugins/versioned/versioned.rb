require File.join(File.dirname(__FILE__), 'accessors')
require File.join(File.dirname(__FILE__), 'class_attributes')
require File.join(File.dirname(__FILE__), 'versioned_model')
require File.join(File.dirname(__FILE__), 'callbacks')
require File.join(File.dirname(__FILE__), 'validations')
require File.join(File.dirname(__FILE__), 'diff')
I18n.load_path << File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'locale', 'en.yml'), __FILE__)

module MongoMapper
  module Plugins
    module Versioned

      extend ActiveSupport::Concern

      include MongoMapper::Plugins::Versioned::Accessors
      include MongoMapper::Plugins::Versioned::ClassAttributes
      include MongoMapper::Plugins::Versioned::VersionedModel
      include MongoMapper::Plugins::Versioned::Callbacks
      include MongoMapper::Plugins::Versioned::Validations
      include MongoMapper::Plugins::Versioned::Diff

      def initialize(*args)
        rolling_back = false
        delete_newer = false

        # set default class attributes and model values
        self[versioned_number_field] = 0
        self[versioned_id_field] = BSON::ObjectId.new
        super
      end

      def rolling_back?
        !!rolling_back
      end

      def delete_newer?
        !!delete_newer
      end

      def save(options={})
        # store some options
        self.do_save_version = true;
        self.do_save_version = false if options.delete(:skip_versioning)
        # check if the scope field is equal to the scope value.
        if (versioned_scope != nil) # any scoping for versioning? e.g. published/draft etc
          self.do_save_version = false if eval(versioned_scope)
        end
        self.updater = options.delete(:updater)
        self.updater_message = options.delete(:updater_message)
        super
      end

      def next_version_number
        if self[versioned_number_field] === 0
          1
        else
          if self.versions.count === 0
            self[versioned_number_field] + 1
          else
            self.versions.first.version_number + 1
          end
        end
      end

      def prepare_version
        @_version = {
          :version_id     =>     BSON::ObjectId.new,
          :version_number =>     self.next_version_number(),
          :doc            =>     self.prepare_versioned_document(),
          :changes        =>     self.versioned_changes()
        }
      end

      def push_version
        return if ((!self.do_save_version) || (@_version === nil))
        # Rolling back?
        if !@_version[:changes].empty? && !delete_newer?
          clear_changes {
            self.versions.create(:data => @_version[:doc],
            :updater => self.updater,
            :updater_message => self.updater_message,
            :versioned => self,
            :version_number => @_version[:version_number],
            :version_id => @_version[:version_id]).tap do |created|
              if created
                update_self_with_new_version_id_and_number(@_version[:version_id], @_version[:version_number])
              end
            end
          }
        end
      ensure
        # reset vars (set during save and prepare)
        self.updater            = nil
        self.updater_message    = nil
        self.do_save_version    = true
        @_version               = nil
      end

      def update_self_with_new_version_id_and_number(version_id, version_number)
        # write new version id and number to document, as it has been updated!
        self.write_attribute(self.class.versioned_id_field, version_id)
        self.write_attribute(self.class.versioned_number_field, version_number)
        self.set(self.class.versioned_id_field => version_id)
        self.set(self.class.versioned_number_field => version_number)
        self.changed_attributes.clear
      end

      def prune_versions
        if self.class.versioned_limit && !self.class.versioned_keep_all_versions
          limit = self.versions.count - self.class.versioned_limit
          if limit > 0
            self.versions.destroy_all(:sort => "#{versioned_number_field.to_s} asc", :limit => limit)
          end
        end
      end

      def prepare_versioned_document
        document = {}
        document.merge!(self.attributes)
        self.class.versioned_non_versioned_keys.each do |remove_key|
          document.delete(remove_key)
        end
        # document.delete(versioned_number_field) # TOOD: check if it's better to keep?
        document
      end

      def versioned_changes
        _version_changes = self.changes
        self.versioned_non_compare_keys.each do |remove_key|
          _version_changes.delete(remove_key)
        end
        _version_changes
      end

      def versions_count
        self.class.version_model.count(:versioned_id => self._id.to_s)
      end

      def destroy_version(version_number)
        if (version_number == :all)
          # still keep own "version"
          self.class.version_model.destroy_all(:versioned_id => self._id.to_s)
        else
          self.class.version_model.destroy_all(:versioned_id => self._id.to_s, :version_number => version_number)
        end
      end

      def destroy_versions(start_version_number, stop_version_number)
        # if keeping self add this:
        # :version_id => {:$ne => self[versioned_id_field]}
        if (stop_version_number == -1)
          version_model.destroy_all(:versioned_id => self._id.to_s, :version_number => {:$gt => start_version_number})
        elsif (start_version_number == -1)
          version_model.destroy_all(:versioned_id => self._id.to_s, :version_number => {:$lt => start_version_number})
        else
          version_model.destroy_all(:versioned_id => self._id.to_s, :version_number => {:$gt => start_version_number, :$lt => stop_version_number})
        end
      end

      # default to rolling back to previous version numbers
      def rollback(version_number = :previous, options = {})
        @rolling_back = true
        assocs_ok = true
        force = options.delete(:force)
        if (!force)
          # TODO
          # verify associations on rollback data before rolling back
        end
        version = self.version_at(version_number)
        if version && assocs_ok
          rollback_remove_keys(version)

          # load attributes/data from version
          version.data.keys.each do |key|
            self.send(:"#{key}=", version.data[key])
          end

          # option to delete versions newer than the rollback one
          rollback_destroy_versions(version) if (options.delete(:delete_newer))

          # default:
          # the rolled back version will be a "new" version, 
          # and all the other versions are just kept as they were
          # TODO option to set rolledback version without creating a "new" version ? 
          # skip_versioning might already do this?
          retval = save!(options) if force
          retval = save(options) unless force
        end
        @rolling_false = true
        @delete_newer = false
        retval
      end

      def rollback!(version_number = :previous, options = {})
        rollback(version_number, options.merge(:force => true))
      end

      def version_at(version_number)
        ver_at = self.class.version_model.where(:versioned_id => self._id.to_s)
        case version_number
        when :first # first possible version stored
          ver_at = ver_at.sort(:version_number.asc).limit(1).first
        when :previous # version before this one.
          ver_at = ver_at.where(:version_number => self[versioned_number_field] - 1).limit(1).first
        when :current # should be same as active
          ver_at = ver_at.sort(:version_number.desc).limit(1).first
        else
          ver_at = ver_at.where(:version_number => version_number).first
        end
      end

    private
      def rollback_remove_keys(version)
        # remove keys by setting them to nil
        remove_keys = self.keys.keys - version.data.keys - self.class.versioned_non_versioned_keys - ["created_at", "updated_at"]
        remove_keys.each do |remove_key|
          self.send(:"#{remove_key}=", nil)
        end
      end

      def rollback_destroy_versions(version)
        destroy_versions(from_version_number, -1)
        @delete_newer = true
        # set version_id and version_number to match version record
        self[versioned_id_field]     = version.version_id
        self[versioned_number_field] = version.version_number        
      end

    end # Module Versioned
  end # Module plugins
end # module MongoMapper
