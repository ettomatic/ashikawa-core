# Ashikawa Core

[![Build Status](https://secure.travis-ci.org/triAGENS/ashikawa-core.png?branch=master)](http://travis-ci.org/triAGENS/ashikawa-core)

Ashikawa Core is a Wrapper around the AvocadoDB Rest API. It provides low level access and will be used in different AvocadoDB ODMs.

## How to use it

For a detailed description of Ashikawa::Core please refer to the [documentation](http://rdoc.info/github/triAGENS/ashikawa-core/master/frames). An example:

```ruby
database = Ashikawa::Core::Database.new "http://localhost:8529"

database["my_collection"] # => Returns the collection my_collection – creates it, if it doesn't exist
database["my_collection"].name = "new_name"
database["new_name"].deleted? # => False
database["new_name"].delete
database["new_name"].deleted? # => True
```

## How to get started developing

Getting started is easy, just follow these steps.

### In a nutshell

* Clone the project.
* `cd` into the folder and run `bundle` 
* `rake` or `rake spec` and see all tests passing.
* Happy coding!

### Detailed description

Make sure you are running Ruby 1.9.x (or JRuby/Rubinius in 1.9 mode) and clone the latest snapshot into a directory of your choice.

If you use `rvm`, create a gemset for this project: `rvm gemset create ashikawa-core`. You will be asked if you want to switch to this gemset once you `cd` into the directory. If you do not want to use `rvm`, just ignore this step.

Change into the project directory. Run `bundle` to get all dependencies (do a `gem install bundler` before if you don't have bundler installed).

Now you can run `rake` or `rake spec` to see all tests passing (hopefully). Happy coding!

You can also start up yard for documentation: `yard server --reload`