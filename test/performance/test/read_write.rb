require File.expand_path(File.join(File.dirname(__FILE__), '..', 'performance_helper'))

require 'benchmark'

DatabaseCleaner.start

Benchmark.bm(22) do |x|
  ids_version = []
  ids_no_version = []
  
  # Write performance
  x.report("write without versioning  ") do
    500.times { |i| ids_no_version << MonkeyNoVersion.create(:name => "Baboo", :age => 12, ).id }
  end
  x.report("write with versioning     ") do
    500.times { |i| ids_version << Monkey.create(:name => "Baboo", :age => 12, ).id }
  end

  # Read performance
  x.report("read with versioning      ") do
    ids_version.each { |id| Monkey.first(:id => id) }
  end
  x.report("read without versioning   ") do
    ids_no_version.each { |id| MonkeyNoVersion.first(:id => id) }
  end
end

DatabaseCleaner.clean
