class Post
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned

  attr_accessible :title, :length
  self.versioned_limit = 5

  key :title, String
  key :length, Integer

  key :content, String

  many :comments
  timestamps!
  # one :user
end
