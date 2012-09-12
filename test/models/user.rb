class User
  include MongoMapper::Document
  attr_accessible :name, :age, :email

  key :name, String
  key :age, Integer
  key :email, String
end
