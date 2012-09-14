class Monkey
  include MongoMapper::Document
  plugin MongoMapper::Plugins::Versioned

  attr_accessible :name, :age
  self.versioned_limit = 5

  key :name, String
  key :age, Integer
end
