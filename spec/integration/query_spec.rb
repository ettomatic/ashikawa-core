require 'integration/spec_helper'

describe "Simple Queries" do
  subject { Ashikawa::Core::Database.new ARANGO_HOST }

  it "should return all documents of a collection" do
    empty_collection = subject["empty_collection"]
    empty_collection.truncate!

    empty_collection << { name: "testname", age: 27}
    empty_collection.all.first["name"].should == "testname"
  end

  it "should be possible to limit and skip results" do
    empty_collection = subject["empty_collection"]
    empty_collection.truncate!

    empty_collection << { name: "test1"}
    empty_collection << { name: "test2"}
    empty_collection << { name: "test3"}

    empty_collection.all(limit: 2).length.should == 2
    empty_collection.all(skip: 2).length.should == 1
  end

  it "should be possible to query documents by example" do
    collection = subject["documenttests"]
    collection.truncate!

    collection << { "name" => "Random Collection" }
    result = collection.by_example example: {"name" => "Random Collection"}
    result.length.should == 1
  end

  it "should be possible to query documents with AQL" do
    collection = subject["aqltest"]
    collection.truncate!

    collection << { "name" => "Jeff Lebowski",    "bowling" => true }
    collection << { "name" => "Walter Sobchak",   "bowling" => true }
    collection << { "name" => "Donny Kerabatsos", "bowling" => true }
    collection << { "name" => "Jeffrey Lebowski", "bowling" => false }

    results = subject.query "FOR u IN aqltest FILTER u.bowling == true RETURN u",
      batch_size: 2,
      count: true

    results.length.should == 3

    results = results.map { |person| person["name"] }
    results.should     include "Jeff Lebowski"
    results.should_not include "Jeffrey Lebowski"
  end

  describe "geolocation" do
    before :each do
      @places = subject['geo_collection']
      @places.truncate!

      @places.add_index :geo, on: [:latitude, :longitude]
      @places << { "name" => "cologne", "latitude" => 50.948045, "longitude" => 6.961212 }
      @places << { "name" => "san francisco", "latitude" => -122.395899, "longitude" => 37.793621 }
    end

    it "should be possible to query documents near a certain location" do
      found_places = @places.near latitude: 50, longitude: 6
      found_places.first["name"].should == "cologne"
    end

    it "should be possible to query documents within a certain range" do
      found_places = @places.within latitude: 50.948040, longitude: 6.961210, radius: 2
      found_places.length.should == 1
      found_places.first["name"].should == "cologne"
    end
  end

  describe "ranges" do
    before :each do
      @people = subject['range_collection']
      @people.truncate!

      @people.add_index :skiplist, on: [:age]
      @people << { "name" => "Georg", "age" => 12 }
      @people << { "name" => "Anne", "age" => 21 }
      @people << { "name" => "Jens", "age" => 49 }
    end

    it "should be possible to query documents for numbers in a certain range" do
      found_people = @people.in_range attribute: "age", left: 20, right: 30, closed: true
      found_people.length.should == 1
      found_people.first["name"].should == "Anne"
    end
  end
end
