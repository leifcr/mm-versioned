module MongoMapper
  module Plugins
    module Versioned
      module VersionedModel
        extend ActiveSupport::Concern
        included do
          const_set(self.versioned_class_name.camelize.to_sym, Class.new).class_eval do
            include MongoMapper::Document

              key :version_number,  Integer
              #key :version_id, ObjectId #String, :typecast => ObjectId
              key :updater_message, String, :default => nil
              key :data, Hash # needed for comparison when saving/updating.

              belongs_to :updater, :polymorphic => true
              belongs_to :versioned, :polymorphic => true

              timestamps!

              def content(key)
                cdata = self.data[key]
                if cdata.respond_to?(:join)
                  cdata.join(" ")
                else
                  cdata
                end
              end  
          end  # const_set

          many :versions, :class_name => self.const_get(versioned_class_name.camelize.to_sym).to_s, :as => :versioned, :sort => :version_number.desc, :dependent => :destroy

          class_attribute :version_model
          self.version_model = self.const_get(versioned_class_name.camelize.to_sym)
        end # included_do
      end
    end # Versioned
  end # Module plugins
end # module MongoMapper