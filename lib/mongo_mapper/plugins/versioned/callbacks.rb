module MongoMapper
  module Plugins
    module Versioned
      module Callbacks
        extend ActiveSupport::Concern        
        included do
          before_save :prepare_version
          after_save :push_version
          after_save :prune_versions
          after_destroy :destroy_versions        
        end # included_do
      end
    end # Versioned
  end # Module plugins
end # module MongoMapper