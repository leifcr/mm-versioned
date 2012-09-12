module MongoMapper
  module Plugins
    module Versioned
      module Accessors
        extend ActiveSupport::Concern
        included do
          attr_accessor :rolling_back
          attr_accessor :updater
          attr_accessor :updater_message
          attr_accessor :do_save_version
          attr_accessor :delete_newer
        end # included do
      end #Accessors
    end # Versioned
  end # Module plugins
end # module MongoMapper