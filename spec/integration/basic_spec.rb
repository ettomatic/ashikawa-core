require 'integration/spec_helper'

describe "Basics" do
  subject { "http://localhost:8529" }

  it "should have booted up an ArangoDB instance" do
    expect { JSON.parse RestClient.get(subject) }.to raise_error(RestClient::NotImplemented)
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
      pending("`<<` not implemented yet")
      empty_collection = subject["empty_collection"]
      empty_collection.length.should == 0
      empty_collection << { name: "testname", age: 27}
      empty_collection << { name: "anderer name", age: 28}
      empty_collection.length.should == 2
      empty_collection.truncate!
      empty_collection.length.should == 0
    end

    it "should return all documents of a collection" do
      pending("`<<` not implemented yet")
      empty_collection = subject["empty_collection"]
      empty_collection << { name: "testname", age: 27}
      empty_collection.all.first["name"].should == "testname"
    end

    it "should be possible to limit and skip results" do
      pending("`<<` not implemented yet")
      empty_collection = subject["empty_collection"]
      empty_collection.truncate!

      empty_collection << { name: "test1"}
      empty_collection << { name: "test2"}
      empty_collection << { name: "test3"}

      empty_collection.all(limit: 2).length.should == 2
      empty_collection.all(skip: 2).length.should == 1
    end


    it "should be possible to access and create documents from a collection" do
      collection = subject["documenttests"]

      pending("`create` not implemented yet")
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

        pending("`<<` not implemented yet")
        @places << { name: "cologne", latitude: 50.948045, longitude: 6.961212 }
        @places << { name: "san francisco", latitude: -122.395899, longitude: 37.793621 }
      end

      it "should be possible to query documents near a certain location" do
        near_places = @places.near latitude: -122.395898, longitude: 37.793622
        near_places.length.should == 1
        near_places.first.name.should == "san francisco"
      end

      it "should be possible to query documents within a certain range" do
        near_places = @places.within latitude: 50.948040, longitude: 6.961210, radius: 2
        near_places.length.should == 1
        near_places.first.name.should == "cologne"
      end
    end

    describe "created document" do
      before :each do
        pending("`create` not implemented yet")
        @collection = subject["documenttests"]
        @document = @collection.create name: "The Dude"
        @document_id = @document.id
      end

      it "should be possible to manipulate documents and save them" do
        @document = @collection[document_id]
        @document["name"] = "Jeffrey Lebowski"
        @document["name"].should == "Jeffrey Lebowski"
        @collection[@document_id].should == "The Dude"
        @document.save
        @collection[@document_id]["name"].should == "Jeffrey Lebowski"
      end

      it "should be possible to delete a document" do
        @collection = subject["documenttests"]
        @document = @collection.create name: "The Dude"
        @document_id = @document.id
        @collection[@document_id].delete
        expect { @collection[@document_id] }.to raise_exception Ashikawa::DocumentNotFoundException
      end
    end

    it "should be possible to query documents by example" do
      collection = subject["documenttests"]

      pending("`<<` not implemented yet")
      collection << { name: "Random Collection" }
      collection.by_example("name" => "Random Collection").length.should == 1
    end
  end
end
