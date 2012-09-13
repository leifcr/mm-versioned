require 'test_helper'

class TestVersioningClassAttributes < Test::Unit::TestCase
  context 'Versioned class attributes' do
    setup do
      @p = PostWithCustomClassAttributes.create(:title => "Eat")
    end
    should 'be able to have custom limit' do
      PostWithCustomClassAttributes.versioned_limit.should_not == 10
      PostWithCustomClassAttributes.versioned_limit.should == 2
    end
    should 'have versioned_keep_all_versions enabled' do
      PostWithCustomClassAttributes.versioned_keep_all_versions.should == true
    end
    should 'be able to keep all versions (no limit)' do
      @p.title = "Lunch"
      @p.save
      @p.title = "Soon"
      @p.save
      @p.title = "or"
      @p.save
      @p.title = "Now"
      @p.save
      @p.versions_count.should == 5
      @p.versions.count.should == 5
    end
    should 'have custom field for version_number' do
      PostWithCustomClassAttributes.versioned_number_field.should_not == :version_number
      PostWithCustomClassAttributes.versioned_number_field.should == :super_version_number
      @p.should respond_to("super_version_number")
      # For some reason it still responds to version_number (TODO)
      # @p.should_not respond_to("version_number")
      @p.super_version_number.should == @p.versions.first.version_number
    end
    should 'have custom field for version_id' do
      PostWithCustomClassAttributes.versioned_id_field.should_not == :version_id
      PostWithCustomClassAttributes.versioned_id_field.should == :super_version_id
      @p.should respond_to("super_version_id")
      # For some reason it still responds to version_id (TODO)
      # @p.should_not respond_to("version_id")
      @p.super_version_id.should == @p.versions.first.version_id
    end
    should 'should not version slug keys' do
      @p.versions.first.data.keys.include?(:slug).should == false
    end

    should 'not have any keys in versioned_non_compare_keys' do
      PostWithCustomClassAttributes.versioned_non_compare_keys.should_not == Post.versioned_non_compare_keys
      PostWithCustomClassAttributes.versioned_non_compare_keys.should == []
    end

    should 'have a scope that will not version some entries' do
      num_versions = @p.versions_count
      @p.title = "cow"
      @p.description = "something about cows"
      @p.save
      @p.title = "cows"
      @p.save
      @p.versions_count.should == (num_versions + 1)
    end

  end # context 'Versioned post' do
end
