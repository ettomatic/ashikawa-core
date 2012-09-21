# Ashikawa Core

[![Build Status](https://secure.travis-ci.org/triAGENS/ashikawa-core.png?branch=master)](http://travis-ci.org/triAGENS/ashikawa-core)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/triAGENS/ashikawa-core)
[![Dependency Status](https://gemnasium.com/triAGENS/ashikawa-core.png)](https://gemnasium.com/triAGENS/ashikawa-core)

Ashikawa Core is a Wrapper around the ArangoDB Rest API. It provides low level access and will be used in different ArangoDB ODMs.

## How to use it

For a detailed description of Ashikawa::Core please refer to the [documentation](http://rdoc.info/github/triAGENS/ashikawa-core/master/frames). An example:

```ruby
database = Ashikawa::Core::Database.new "http://localhost:8529"

database["my_collection"] # => Returns the collection my_collection – creates it, if it doesn't exist
database["my_collection"].name = "new_name"
database["new_name"].delete
```

# Contributing

If you want to contribute to the project, see CONTRIBUTING.md for details.
