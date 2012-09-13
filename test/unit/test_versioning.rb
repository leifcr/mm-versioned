require 'test_helper'

class VersioningTest < Test::Unit::TestCase
  context 'Versioned post' do
    setup do
      @post = Post.create(:title => 'Sugar Donkey', :length => 41)
      @post.title = "Monkey Business"
      @post.length = 12
      @post.save
      @post.title = "Cat Fighter"
      @post.content = "Not in fight club"
      @post.length = 500
      @post.comments << Comment.new(:title => 'Cool cat fighters', :date => Time.now)
      @post.save
    end

    context 'when verifying' do
      should 'not return nil for versions_count' do
        @post.versions_count.should_not == nil
      end

      should 'have 3 versions through association' do
        @post.versions.count.should == 3
      end

      should 'have 3 versions through query' do
        @post.versions_count.should == 3
      end

      should 'find previous version' do
        @post.version_at(:previous).data["title"].should == "Monkey Business"
      end

      should 'find first version' do
        @post.version_at(:first).data["title"].should == "Sugar Donkey"
      end

      should 'find version with version number 2' do
        @post.version_at(2).data["title"].should == "Monkey Business"
      end

      should "verify length and title on each version" do
        @post.versions[0].data["title"] == "Cat Fighter"
        @post.versions[0].data["length"].should == 500
        @post.versions[1].data["title"] == "Monkey Business"
        @post.versions[1].data["length"].should == 12
        @post.versions[2].data["title"].should == 'Sugar Donkey'
        @post.versions[2].data["length"].should == 41
      end
      should 'verify version numbers on versions' do
        @post.versions[0].version_number.should == 3
        @post.versions[1].version_number.should == 2
        @post.versions[2].version_number.should == 1
      end

      should 'only create a new version data is changed' do
        versions_count = @post.versions_count
        @post.save
        versions_count.should == @post.versions_count
      end

      should 'only store 5 versions as specificed by version_limit' do
        @post.title = 'Elephant Fart'
        @post.save
        @post.title = "Cow Patrol"
        @post.save
        @post.title = "Horse Power"
        @post.save
        @post.versions_count.should == 5
      end
    end

    context 'when rolling back' do
      context 'and loading previous version' do
        setup do
          @post.rollback(:previous).should == true
        end
        should 'verify title and length attribute' do
          @post.title.should == "Monkey Business"
          @post.length.should == 12
        end
        should 'verify number of versions' do
          @post.versions.reload.count.should == 4
        end
        should 'verify version number' do
          @post.version_number.should == 4
        end
        should 'verify version_id on post and rolled back version' do
          @post[@post.class.versioned_id_field].should == @post.versions.first.version_id
        end
      end

      should 'load first version' do
        @post.rollback(:first).should == true
        @post.title.should == "Sugar Donkey"
        @post.length.should == 41
      end

      should 'load first version and delete newer history' do
        @post.rollback(:first, {:delete_newer => true}).should == true
        @post.title.should == "Sugar Donkey"
        @post.length.should == 41
        @post.versions.count.should == 1
      end

      should 'load specific version on rollback' do
        @post.title = "Cow Patrol"
        @post.save
        @post.title = "Horse Power"
        @post.save
        @post.rollback(2).should == true
        @post.title.should == "Monkey Business"
        @post.length.should == 12
      end

      should "allow protected attributes to be reverted or removed" do
        @post.content = "Pffft... Cat Figher?"
        @post.title = "Elephant Fart"
        @post.save
        @post.rollback!(:previous)
        @post.content.should_not == "Pffft... Cat Figher?"
        @post.content.should == "Not in fight club"
      end

    end # context 'when rolling back' do

    context 'when deleting versions' do
      should "delete all versions" do
        @post.destroy_version(:all)
        @post.versions.reload
        @post.versions.count.should == 0
      end
      should "delete specific version" do
        @post.destroy_version(3)
        @post.versions.reload
        @post.version_at(3).should == nil
        @post.versions_count.should == 2
      end
    end #context 'when deleting versions' do

    context 'when using update_attributes' do
      should 'create a new version as usual' do
        versions_count = @post.versions_count
        @post.update_attributes(:title => "Elephant Fart")
        @post.reload
        @post.title.should == "Elephant Fart"
        @post.versions_count.should == (versions_count + 1)
      end
      should 'not create a new version when there are no changes' do
        versions_count = @post.versions_count
        @post.update_attributes
        @post.versions_count.should == versions_count
      end
    end #context 'Versioning with update_attributes' do

    context 'when assigning additional data to the version' do
      should 'create a new version with an updater set' do
        user = User.create(:name => "Monkey King", :age => 235, :email => "monkeyking@mailinator.com")
        @post.title = 'Elephant Fart is ruled by the Monkey King'
        @post.save(:updater => user)
        @post.versions.first.updater_id.should == user._id
        @post.versions.first.updater.should == user
      end
      should 'create a new version with an updater message set' do
        @post.title = 'Elephant Fart'
        @post.save(:updater_message => "Are you sure you want to smell?")
        @post.versions.first.updater_message.should == "Are you sure you want to smell?"
      end
      should 'create a new version with an updater and updater message set' do
        user = User.create(:name => "Monkey King", :age => 235, :email => "monkeyking@mailinator.com")
        @post.title = 'Elephant Fart'
        @post.save(:updater => user, :updater_message => "Are you sure you want to smell?")
        @post.versions.first.updater_message.should == "Are you sure you want to smell?"
        @post.versions.first.updater_id.should == user._id
        @post.versions.first.updater.should == user
      end
    end #context 'assigning additonal data' do
  end # context 'Versioned post' do

  # TODO
  # context 'Versioned post with different version class' do
  #   setup do
  #     @post = PostWithHistoryClassName.create(:title => 'Sugar Donkey')
  #     @post.title = "Monkey Business"
  #     @post.save
  #   end
  #   should 'verify custom class on model' do
  #     Post.version_model.name.should == "Post::History"
  #   end
  #   should 'have 2 versions' do
  #     @post.versions_count.should == 2
  #   end
  #   should 'be able to rollback' do
  #     @post.rollback(:previous)
  #     @post.title.should == "Sugar Donkey"
  #   end
  # end
end
