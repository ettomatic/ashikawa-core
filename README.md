# Ashikawa Core

[![Build Status](https://secure.travis-ci.org/triAGENS/ashikawa-core.png?branch=master)](http://travis-ci.org/triAGENS/ashikawa-core)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/triAGENS/ashikawa-core)
[![Dependency Status](https://gemnasium.com/triAGENS/ashikawa-core.png)](https://gemnasium.com/triAGENS/ashikawa-core)

Ashikawa Core is a Wrapper around the ArangoDB Rest API. It provides low level access and will be used in different ArangoDB ODMs.

All tests run on Travis CI for the following versions of Ruby:

* MRI 1.9.2 and 1.9.3
* Rubinius 1.9 mode
* JRuby 1.9 mode

We also run on JRuby and MRI Head. MRI-head is currently not passing, because some dependencies are not compatible.

Please note that the `master` branch is always the stable version released on Ruby Gems. If you want the most recent version, please refer to the `development` branch.

## How to use it

For a detailed description of Ashikawa::Core please refer to the [documentation](http://rdoc.info/github/triAGENS/ashikawa-core/master/frames). An example:

```ruby
database = Ashikawa::Core::Database.new "http://localhost:8529"

database["my_collection"] # => Returns the collection my_collection – creates it, if it doesn't exist
database["my_collection"].name = "new_name"
database["new_name"].delete
```

# Issues or Questions

If you find a bug in this gem, please report it on [our tracker](https://github.com/triAGENS/ashikawa-core/issues). If you have a question, just contact us via the [mailing list](https://groups.google.com/forum/?fromgroups#!forum/ashikawa) – we are happy to help you :)

# Contributing

If you want to contribute to the project, see CONTRIBUTING.md for details. It contains information on our process and how to set up everything.
