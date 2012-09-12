class PostWithHistoryClassName
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned
  self.versioned_limit = 5
  self.versioned_class_name = "history"

  attr_accessible :title

  key :title, String

  timestamps!
end
