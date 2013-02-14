# Ashikawa Core

[![Gem Version](https://badge.fury.io/rb/ashikawa-core.png)](http://badge.fury.io/rb/ashikawa-core)
[![Build Status](https://secure.travis-ci.org/triAGENS/ashikawa-core.png?branch=master)](http://travis-ci.org/triAGENS/ashikawa-core)
[![Dependency Status](https://gemnasium.com/triAGENS/ashikawa-core.png)](https://gemnasium.com/triAGENS/ashikawa-core)
[![Code Climate](https://codeclimate.com/github/triAGENS/ashikawa-core.png)](https://codeclimate.com/github/triAGENS/ashikawa-core)

Ashikawa Core is a Wrapper around the ArangoDB Rest API. It provides low level access and will be used in different ArangoDB ODMs and other projects related to the database. It is always working with the stable version of ArangoDB, this is currently version **1.1.2**.

All tests run on Travis CI for the following versions of Ruby:

* MRI 1.8.7, 1.9.2 and 1.9.3
* Rubinius 1.8 and 1.9 mode
* JRuby 1.8 and 1.9 mode
* REE

We also run on JRuby and MRI Head, but they are allowed failures (Please see [Travis](http://travis-ci.org/triAGENS/ashikawa-core) for their build status).

Please note that the `master` branch is always the stable version released on Ruby Gems and documented on RDoc. If you want the most recent version, please refer to the `development` branch.

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

If you want to contribute to the project, see CONTRIBUTING.md for details. It contains information on our process and how to set up everything. The following people have contributed to this project:

* Lucas Dohmen (@moonglum): Developer
* Tobias Eilert (@EinLama): Contributor
* Markus Schirp (@mbj): Contributor
