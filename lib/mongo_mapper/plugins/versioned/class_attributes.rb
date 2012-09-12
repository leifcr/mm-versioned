module MongoMapper
  module Plugins
    module Versioned
      module ClassAttributes
        extend ActiveSupport::Concern
        included do
          class_attribute :versioned_limit
          self.versioned_limit ||= 10

          class_attribute :versioned_keep_all_versions
          self.versioned_keep_all_versions ||= false

          class_attribute :versioned_number_field
          self.versioned_number_field ||= :version_number          
          key versioned_number_field, Integer, :default => 0

          class_attribute :versioned_id_field
          self.versioned_id_field ||= :version_id

          #key :version_id, ObjectId, :default => lambda { BSON::ObjectId.new }
          key versioned_id_field, ObjectId, :default => lambda { BSON::ObjectId.new }
          # key versioned_id_field, String#, :typecast => ObjectId #BSON::ObjectId# => "monkey" #, :default => BSON::ObjectId.new

          class_attribute :versioned_class_name
          self.versioned_class_name ||= "version"

          class_attribute :versioned_non_versioned_keys
          self.versioned_non_versioned_keys   = [ "_id", "_type", "#{self.versioned_number_field.to_s}", "#{self.versioned_id_field.to_s}"]

          class_attribute :versioned_non_compare_keys
          self.versioned_non_compare_keys = ["created_at", "updated_at"]

          class_attribute :versioned_scope
          self.versioned_scope ||= nil

        end # included_do
      end # Class Attributes
    end # Versioned
  end # Module plugins
end # module MongoMapper