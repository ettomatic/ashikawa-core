# Ashikawa Core

[![Build Status](https://secure.travis-ci.org/triAGENS/ashikawa-core.png?branch=master)](http://travis-ci.org/triAGENS/ashikawa-core)

Ashikawa Core is a Wrapper around the AvocadoDB Rest API. It provides low level access and will be used in different AvocadoDB ODMs.

## How to use it

For a detailed description of Ashikawa::Core please refer to the [documentation](http://rdoc.info/github/triAGENS/ashikawa-core/master/frames). An example:

```ruby
database = Ashikawa::Core::Database.new "http://localhost:8529"

database["my_collection"] # => Returns the collection my_collection – creates it, if it doesn't exist
database["my_collection"].name = "new_name"
database["new_name"].delete
```

## How to get started developing

Getting started is easy, just follow these steps.

### In a nutshell

* Clone the project.
* `cd` into the folder and run `bundle` 
* `rake` and see all tests passing (you need to have AvocadoDB installed for that)
* Happy coding!

### Detailed description

Make sure you are running Ruby 1.9.x (or JRuby/Rubinius in 1.9 mode) and clone the latest snapshot into a directory of your choice. Also make sure AvocadoDB is installed and accessible via `avocado`.

We encourage you to use [rvm](https://rvm.io/). If you do so, a gemset for the project is created upon changing into the directory. If you do not use `rvm` nothing special will happen in this case. Don't worry about it.

Change into the project directory. Run `bundle` to get all dependencies (do a `gem install bundler` before if you don't have bundler installed).

Now you can run `rake` to see all tests passing (hopefully). Happy coding!

You can also start up yard for documentation: `rake yard:server`

## Contributing

When you want to write code for the project, please follow these guidelines:

1. Claim the ticket: Tell us that you want to work on a certain ticket, we will assign it to you (We don't want two people to work on the same thing ;) )
2. Write an Integration Test: Describe what you want to do (our integration tests touch the database)
3. Implement it: Write a unit test, check that it fails, make the test pass – repeat (our unit tests don't touch the database)
4. Write Documentation for it: Check the compatability with our rules via *yardstick*
5. Check with `rake` that everything is fine and send the Pull Request :)

## Documentation

We want `Ashikawa::Core` to be a solid foundation for all Ruby Libraries connecting to AvocadoDB. Therefore we want an excellent documentation. We created two rake tasks:

* `rake yard:report`: Measure docs in lib/**/*.rb with yardstick
* `rake yard:verify`: Verify that yardstick coverage is 100%

The Yardstick coverage will be checked by our CI. Please make sure that the coverage is always at 100%.