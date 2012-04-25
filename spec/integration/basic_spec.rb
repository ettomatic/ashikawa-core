require 'integration/spec_helper'

describe "Basics" do
  subject { "http://localhost:8529" }
  
  it "should have booted up an AvocadoDB instance" do
    expect { JSON.parse RestClient.get(subject) }.to raise_error(RestClient::NotImplemented)
  end
  
  describe "initialized database" do
    subject { Ashikawa::Core::Database.new "http://localhost:8529" }
  
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
      my_collection.wait_for_sync?.should be_false
      my_collection.wait_for_sync = true
      my_collection.wait_for_sync?.should be_true
    end
    
    it "should be possible to get information about the number of documents"
    # Should use the following:
    # collection.length
    # collection.all
    # collection.truncate
    # collection.<<
    
    it "should be possible to limit and skip results"
    # Should use the following:
    # collection.limit
    # collection.skip
    
    it "should be possible to query documents via geo information"
    # Should use the following:
    # collection.near
    # collection.within
    
    it "should be possible to query documents by example"
    # Should use the following:
    # collection.by_example
    
  end
end