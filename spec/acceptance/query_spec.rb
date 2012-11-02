require 'acceptance/spec_helper'

describe "Simple Queries" do
  let(:database) { Ashikawa::Core::Database.new ARANGO_HOST }
  subject { database["my_collection"] }
  before(:each) { subject.truncate! }

  it "should return all documents of a collection" do
    subject << { name: "testname", age: 27}
    subject.all.first["name"].should == "testname"
  end

  it "should be possible to limit and skip results" do
    subject << { name: "test1"}
    subject << { name: "test2"}
    subject << { name: "test3"}

    subject.all(limit: 2).length.should == 2
    subject.all(skip: 2).length.should == 1
  end

  it "should be possible to query documents by example" do
    subject << { "name" => "Random Document" }
    result = subject.by_example name: "Random Document"
    result.length.should == 1
  end

  it "should be possible to query documents with AQL" do
    subject << { "name" => "Jeff Lebowski",    "bowling" => true }
    subject << { "name" => "Walter Sobchak",   "bowling" => true }
    subject << { "name" => "Donny Kerabatsos", "bowling" => true }
    subject << { "name" => "Jeffrey Lebowski", "bowling" => false }

    results = database.query "FOR u IN my_collection FILTER u.bowling == true RETURN u",
      batch_size: 2,
      count: true

    results.length.should == 3

    results = results.map { |person| person["name"] }
    results.should     include "Jeff Lebowski"
    results.should_not include "Jeffrey Lebowski"
  end

  describe "geolocation" do
    before :each do
      subject.add_index :geo, on: [:latitude, :longitude]
      subject << { "name" => "cologne", "latitude" => 50.948045, "longitude" => 6.961212 }
      subject << { "name" => "san francisco", "latitude" => -122.395899, "longitude" => 37.793621 }
    end

    it "should be possible to query documents near a certain location" do
      found_places = subject.near latitude: 50, longitude: 6
      found_places.first["name"].should == "cologne"
    end

    it "should be possible to query documents within a certain range" do
      found_places = subject.within latitude: 50.948040, longitude: 6.961210, radius: 2
      found_places.length.should == 1
      found_places.first["name"].should == "cologne"
    end
  end

  describe "ranges" do
    before :each do
      subject.add_index :skiplist, on: [:age]
      subject << { "name" => "Georg", "age" => 12 }
      subject << { "name" => "Anne", "age" => 21 }
      subject << { "name" => "Jens", "age" => 49 }
    end

    it "should be possible to query documents for numbers in a certain range" do
      found_people = subject.in_range attribute: "age", left: 20, right: 30, closed: true
      found_people.length.should == 1
      found_people.first["name"].should == "Anne"
    end
  end
end
