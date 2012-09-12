# encoding: UTF-8
require File.join(File.dirname(__FILE__), 'lib','mongo_mapper', 'plugins', 'versioned', 'version')

Gem::Specification.new do |s|
  s.name                          = 'mm-versioned'
  s.homepage                      = 'http://github.com/leifcr/mm-versioned'
  s.summary                       = 'A MongoMapper extension adding Versioning'
  s.require_paths                 = ['lib']
  s.authors                       = ['Leif Ringstad']
  s.email                         = 'leifcr@gmail.com'
  s.version                       = MongoMapper::Versioned::VERSION
  s.platform                      = Gem::Platform::RUBY
  s.files                         = Dir.glob('lib/**/*') + %w[config.ru Gemfile Rakefile README.md]
  s.test_files                    = Dir.glob('test/**/*')

  s.add_dependency 'i18n'
  # s.add_dependency 'differ'
  s.add_dependency 'diffy'
  s.add_dependency 'builder'
  s.add_dependency 'bson'
  s.add_dependency 'activesupport'
  s.add_dependency 'i18n'
  s.add_dependency 'mongo_mapper', '~> 0.11.2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'ruby-debug19'
end
