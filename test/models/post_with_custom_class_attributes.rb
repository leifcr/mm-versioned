class PostWithCustomClassAttributes
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned
  self.versioned_limit = 2
  self.versioned_keep_all_versions = true
  self.versioned_number_field = :super_version_number
  self.versioned_id_field = :super_version_id
  self.versioned_non_versioned_keys = [ "_id", "_type", "#{self.versioned_number_field.to_s}", "#{self.versioned_id_field.to_s}", "slug" ]
  self.versioned_non_compare_keys = []
  self.versioned_scope = "self.title == \"cow\""

  attr_accessible :title, :slug

  key :title, String
  key :slug, String
  key :description, String

  timestamps!
end
