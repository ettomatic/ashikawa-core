require 'integration/spec_helper'

describe "Basics" do
  subject { ARANGO_HOST }

  # it "should have booted up an ArangoDB instance" do
    # expect { RestClient.get(subject) }.to_not raise_error
  # end

  describe "initialized database" do
    subject { Ashikawa::Core::Database.new ARANGO_HOST }

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
  end

  describe "created document" do
    let(:database) { Ashikawa::Core::Database.new ARANGO_HOST }
    let(:collection) { database["documenttests"] }
    subject { collection.create name: "The Dude" }
    let(:document_id) { subject.id }

    it "should be possible to manipulate documents and save them" do
      subject["name"] = "Jeffrey Lebowski"
      subject["name"].should == "Jeffrey Lebowski"
      collection[document_id]["name"].should == "The Dude"
      subject.save
      collection[document_id]["name"].should == "Jeffrey Lebowski"
    end

    it "should be possible to delete a document" do
      collection[document_id].delete
      expect {
        collection[document_id]
      }.to raise_exception Ashikawa::Core::DocumentNotFoundException
    end

    it "should not be possible to delete a document that doesn't exist" do
      expect {
        collection[123].delete
      }.to raise_exception Ashikawa::Core::DocumentNotFoundException
    end
  end
end
