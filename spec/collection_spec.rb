require 'spec_helper'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Collection }
  
  before :each do
    @database = double()
  end
  
  it "should have a name" do
      my_collection = subject.new @database, server_response("/collections/4588")
      my_collection.name.should == "example_1"
    end
    
  it "should accept an ID" do
    my_collection = subject.new @database, server_response("/collections/4588")
    my_collection.id.should == 4588
  end
  
  describe "the status code" do
    it "should know if the collection is new born" do
      my_collection = subject.new @database, { "status" => "1" }
      my_collection.new_born?.should == true
    
      my_collection = subject.new @database, { "status" => "200" }
      my_collection.new_born?.should == false
    end
  
    it "should know if the collection is unloaded" do
      my_collection = subject.new @database, { "status" => "2" }
      my_collection.unloaded?.should == true
    
      my_collection = subject.new @database, { "status" => "200" }
      my_collection.unloaded?.should == false
    end
  
    it "should know if the collection is loaded" do
      my_collection = subject.new @database, { "status" => "3" }
      my_collection.loaded?.should == true
    
      my_collection = subject.new @database, { "status" => "200" }
      my_collection.loaded?.should == false
    end
  
    it "should know if the collection is being unloaded" do
      my_collection = subject.new @database, { "status" => "4" }
      my_collection.being_unloaded?.should == true
    
      my_collection = subject.new @database, { "status" => "200" }
      my_collection.being_unloaded?.should == false
    end
    
    it "should know if the collection is deleted" do
      my_collection = subject.new @database, { "status" => "5" }
      my_collection.deleted?.should == true
    
      my_collection = subject.new @database, { "status" => "200" }
      my_collection.deleted?.should == false
    end
    
    it "should know if the collection is corrupted" do
      my_collection = subject.new @database, { "status" => "6" }
      my_collection.corrupted?.should == true
    end
  end
  
  describe "attributes of a collection" do
    it "should check if the collection waits for sync" do
      @database.stub(:send_request).with("/collection/4590/parameter").and_return { server_response("/collections/4590") }
      @database.should_receive(:send_request).with("/collection/4590/parameter")
      
      my_collection = subject.new @database, { "id" => "4590" }
      my_collection.wait_for_sync?.should be_true
    end
    
    it "should know how many documents the collection has" do
      @database.stub(:send_request).with("/collection/4590/count").and_return { server_response("/collections/4590-parameter") }
      @database.should_receive(:send_request).with("/collection/4590/count")
      
      my_collection = subject.new @database, { "id" => "4590" }
      my_collection.length.should == 54
    end
    
    it "should check for the figures" do
      @database.stub(:send_request).with("/collection/73482/figures").and_return { server_response("/collections/73482-figures") }
      @database.should_receive(:send_request).with("/collection/73482/figures")
      
      my_collection = subject.new @database, { "id" => "73482" }
      my_collection.figure(:datafiles_count).should == 1
      my_collection.figure(:alive_size).should == 0
      my_collection.figure(:alive_count).should == 0
      my_collection.figure(:dead_size).should == 2384
      my_collection.figure(:dead_count).should == 149      
    end
  end
  # describe "an initialized collection" do
  #   
  # end
end