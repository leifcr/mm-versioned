class Comment
  include MongoMapper::EmbeddedDocument
  key :date, Time
  key :title, String
end
