mm-versioned
============
A MongoMapper plugin which enables document versioning.
Even though there are mm-revisionable, mm-versionable, versioned and mongomapper-versioned, I needed different features.
This has some ideas from all of mentioned, but with still a new implementation.

[![Build Status](https://secure.travis-ci.org/leifcr/mm-versioned.png)](http://travis-ci.org/leifcr/mm-versioned) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/leifcr/mm-versioned)

Installation
------------------------------------
Until it's released as a gem:

    gem 'mm-versioned', :git => 'https://github.com/leifcr/mm-versioned.git'

Usage
------------------------------------

### Example usage

#### In your model
Add plugin MongoMapper::Plugins::Versioned like this:

    class Post
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Versioned

        key :title, String
    end

#### Create as normal

    post = Post.create(:name => 'Cows are cool')

#### Update as normal

    post.title = 'Sheep are cooler'
    post.save

#### Add an updater and/or a message when saving

    post.save :updater => current_user, :updater_message => "Yes I updated this"

    post.updater # => current_user Note: will be equal to current_user (expected to be a mongo object in a collection)
    post.updater_message # => "Yes I updated this"

Note: current_user is assumed to be a valid MongoMapper Model that will be associated through a has_one association.

#### Don't save a version when updating/saving
    
    post.save(:skip_versioning => true)

#### Rolling back

    post.rollback(:first)
    post.rollback(:previous)
    post.rollback(1) # must be valid, or empty is returned

#### Counting versioned documents
Count through association

    post.versions.count # => 2
Count using query and count feature of MongoMapper/MongoDB

    post.versions_count # => 2

#### Get versions

##### Through association
Note: This gives you a special "versioned type" with the original documents data stored in data

    post.versions # returns a plucky query
    post.versions.all # => All the versions

    post.versions.first.data # => returns the attributes for the original document

##### Through methods
For versioned documents:

    post.version_at(:first) # or :previous or index (same as rolling back)

To get the original document as a version without rolling back:
NOTE: The ID of the document is set to the same as the original. If you save/update, you might overwrite your original document. Write tests where you use this to avoid issues.

    post.original_document_at(:first) # or :previous or index (same as rolling back)

    post.original_document_at(:first, :new_id => true) # The returned document will have a new ID so you can save that as a "copy" if you want to.


#### Options you can put in your model

    class Post
        include MongoMapper::Document
        plugin MongoMapper::Plugins::Versioned

        key :title, String
        key :age, Integer

        self.versioned_number_field = :a_different_field_to_have_version_number_in 
        # (default: :version_number)
        
        self.versioned_id_field     = :a_different_field_to_have_version_id_in 
        # (default: :version_id)
        
        self.versioned_keep_all_versions = true 
        # will not use limit, and all versions are kept.
        # (default: false) 
        
        self.versioned_non_versioned_keys = ["_id", "title"] 
        # will not version the title on the post
        # (default: [ "_id", "_type", "#{self.versioned_number_field.to_s}", "#{self.versioned_id_field.to_s}"]) 

        self.versioned_non_compare_keys = ["updated_at"]
        # keys that should be ignored when checking for changes between the current document and the new version to-be-saved
        # (default: ["created_at", "updated_at"])

        self.versioned_scope = "self.title != \"Don't store this\""
        # scope for when versioning should happen. Check throuh eval(self.versioned_scope)
        # (default: nil)
    end

_Read the tests to see other options/methods_

Problems or Questions?
------------------------------------
Twitter @leifcr
Use [github issues](https://github.com/leifcr/mm-versioned/issues) for bugs

Note on Patches/Pull Requests
------------------------------------
- Make your feature addition or bug fix.
- Write tests! Travis-CI!

Thanks
------------------------------------
John Nunemaker, Brandon Keepers & others - [_MongoMapper_](github.com/jnunemaker/mongomapper) - 
10gen  - [_MongoDB_](http://www.mongodb.org)

Artha42 - [_mm-versionable_](https://github.com/artha42/mm-versionable)
Gigamo - [_mongo_mapper_acts_as_versioned_](https://github.com/gigamo/mongo_mapper_acts_as_versioned)
Justin Karimi - [_mm-revisionable_](https://github.com/billy-ran-away/mm-revisionable)
Christopher Burnett - [_versioned_](https://github.com/twoism/versioned) 
Alex Wolfe - [_mongomapper-versioned_](https://github.com/alexkwolfe/mongomapper-versioned)

Copyright
------------------------------------
See LICENSE for details.
