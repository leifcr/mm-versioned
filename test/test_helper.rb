require 'rubygems'
require 'bundler/setup'
require 'rails'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'versioned'

Bundler.require(:default, :test)

MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => Rails.logger)
MongoMapper.database = "mm-versioned-test"

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each {|file| require file}

DatabaseCleaner.strategy = :truncation

class Test::Unit::TestCase
  # Drop all collections after each test case.
  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  # Make sure that each test case has a teardown
  # method to clear the db after each test.
  def inherited(base)
    base.define_method setup do
      super
    end

    base.define_method teardown do
      super
    end
  end

  custom_matcher :respond_to do |receiver, matcher, args|
    respond_to = args[0]
    matcher.positive_failure_message = "Expected #{receiver.class.name} to have method #{respond_to}, but it didn't"
    matcher.negative_failure_message = "Expected #{receiver.class.name} to NOT have method #{respond_to}, but it did"
    receiver.respond_to?(respond_to)
  end

end
