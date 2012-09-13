require 'test_helper'

class TestVersioningDiff < Test::Unit::TestCase
  context 'when doing diff between versioned posts' do
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
    should 'get html diff' do
      @post.diff(1,2,:html).should == "<div class=\"diff\"><div class=\"single_diff\"><div class=\"key_title\">title</div><div class=\"del\">Sugar Donkey</div></div><div class=\"single_diff\"><div class=\"key_title\">title</div><div class=\"add\">Monkey Business</div></div><div class=\"single_diff\"><div class=\"key_title\">length</div><div class=\"del\">41</div></div><div class=\"single_diff\"><div class=\"key_title\">length</div><div class=\"add\">12</div></div></div>"
    end
    should 'get ascii diff' do
      @post.diff(1,2,:ascii).should == "Key: title\n----------\n-Sugar Donkey\n+Monkey Business\n\nKey: length\n-----------\n-41\n+12\n\nKey: comments\n-------------\n \n\n"
    end
  end # context 'when doing diff between versioned posts' do
end
