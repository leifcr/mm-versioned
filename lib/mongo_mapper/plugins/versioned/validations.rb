module MongoMapper
  module Plugins
    module Versioned
      module Validations
        extend ActiveSupport::Concern        
        
        included do
          validate :verify_updating_latest_version, :on => :update
        end # included_do
        
        def verify_updating_latest_version
          # don't validate if rolling back
          return if rolling_back?
          newest_ver = self.versions.reload.first
          if (newest_ver.versioned_id != self._id) || (newest_ver.version_id != self[versioned_id_field])
              errors.add(:base,  I18n.t(:trying_to_update_old_version, { \
                  :model_name => self.class.name, \
                  :newest_version_number => newest_ver.version_number, \
                  :newest_version_id => newest_ver.version_id, \
                  :old_version_number => self[versioned_number_field], \
                  :old_version_id => self[versioned_id_field], \
                  :scope => [:mongo_mapper, :errors, :messages, :versioned]})) 
          end
        end # def verify_updating_latest_version

      end # Validations
    end # Versioned
  end # Module plugins
end # module MongoMapper