require 'integration/spec_helper'

describe "Basics" do
  subject { "http://localhost:8529" }

  it "should have booted up an ArangoDB instance" do
    RestClient.get(subject).should include("Arango")
  end

  describe "initialized database" do
    subject { Ashikawa::Core::Database.new "http://localhost:8529" }

    after :each do
      subject.collections.each { |collection| collection.delete }
    end

    it "should do what the README describes" do
      subject["my_collection"]
      subject["my_collection"].name = "new_name"
      subject["new_name"].delete
    end

    it "should create and delete collections" do
      subject.collections.should ==[]
      subject["collection_1"]
      subject["collection_2"]
      subject["collection_3"]
      subject.collections.length.should == 3
      subject["collection_3"].delete
      subject.collections.length.should == 2
    end

    it "should be possible to change the name of a collection" do
      my_collection = subject["test_collection"]
      my_collection.name.should == "test_collection"
      my_collection.name = "my_new_name"
      my_collection.name.should == "my_new_name"
    end

    it "should be possible to find a collection by ID" do
      my_collection = subject["test_collection"]
      subject[my_collection.id].name.should == "test_collection"
    end

    it "should be possible to load and unload collections" do
      my_collection = subject["test_collection"]
      my_collection.loaded?.should be_true
      my_collection.unload
      my_id = my_collection.id
      my_collection = subject[my_id]
      subject[my_id].loaded?.should be_false
    end

    it "should be possible to get figures" do
      my_collection = subject["test_collection"]
      my_collection.figure(:datafiles_count).class.should == Fixnum
      my_collection.figure(:alive_size).class.should == Fixnum
      my_collection.figure(:alive_count).class.should == Fixnum
      my_collection.figure(:dead_size).class.should == Fixnum
      my_collection.figure(:dead_count).class.should == Fixnum
    end

    it "should change and receive information about waiting for sync" do
      my_collection = subject["my_collection"]
      my_collection.wait_for_sync = false
      my_collection.wait_for_sync?.should be_false
      my_collection.wait_for_sync = true
      my_collection.wait_for_sync?.should be_true
    end

    it "should be possible to get information about the number of documents" do
      empty_collection = subject["empty_collection"]
      empty_collection.length.should == 0
      empty_collection << { name: "testname", age: 27}
      empty_collection << { name: "anderer name", age: 28}
      empty_collection.length.should == 2
      empty_collection.truncate!
      empty_collection.length.should == 0
    end

    it "should return all documents of a collection" do
      empty_collection = subject["empty_collection"]
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

    it "should be possible to update the attributes of a document" do
      collection = subject["documenttests"]

      document = collection.create name: "The Dude", bowling: true
      document_id = document.id
      document["name"] = "Other Dude"
      document.save

      collection[document_id]["name"].should == "Other Dude"
    end

    it "should be possible to access and create documents from a collection" do
      collection = subject["documenttests"]

      document = collection.create name: "The Dude", bowling: true
      document_id = document.id
      collection[document_id]["name"].should == "The Dude"

      collection[document_id] = { name: "Other Dude", bowling: true }
      collection[document_id]["name"].should == "Other Dude"
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

    describe "created document" do
      before :each do
        @collection = subject["documenttests"]
        @document = @collection.create name: "The Dude"
        @document_id = @document.id
      end

      it "should be possible to manipulate documents and save them" do
        @document = @collection[@document_id]
        @document["name"] = "Jeffrey Lebowski"
        @document["name"].should == "Jeffrey Lebowski"
        @collection[@document_id]["name"].should == "The Dude"
        @document.save
        @collection[@document_id]["name"].should == "Jeffrey Lebowski"
      end

      it "should be possible to delete a document" do
        @collection = subject["documenttests"]
        @document = @collection.create name: "The Dude"
        @document_id = @document.id
        @collection[@document_id].delete
        expect { @collection[@document_id] }.to raise_exception Ashikawa::Core::DocumentNotFoundException
      end

      it "should not be possible to delete a document that doesn't exist" do
        @collection = subject["documenttests"]
        expect { @collection[123].delete }.to raise_exception Ashikawa::Core::DocumentNotFoundException
      end
    end

    describe "setting and deleting indices" do
      before :each do
        @collection = subject["documenttests"]
      end

      it "should be possible to set indices" do
        @collection.add_index :geo, on: [:latitude, :longitude]
        @collection.add_index :skiplist, on: [:identifier]
        @collection.indices.length.should == 3 # primary index is always set
        @collection.indices[0].class.should == Ashikawa::Core::Index
      end

      it "should be possible to get an index by ID" do
        index = @collection.add_index :skiplist, on: [:identifier]
        @collection.index(index.id).id.should == index.id
      end

      it "should be possible to remove indices" do
        index = @collection.add_index :skiplist, on: [:identifier]
        index.delete
        @collection.indices.length.should == 1 # primary index is always set
      end
    end

    describe "querying for documents" do
      it "should be possible to query documents by example" do
        collection = subject["documenttests"]

        collection << { "name" => "Random Collection" }
        result = collection.by_example example: {"name" => "Random Collection"}
        result.length.should == 1
      end

      it "should be possible to query documents with AQL" do
        collection = subject["aqltest"]

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
    end
  end
end
