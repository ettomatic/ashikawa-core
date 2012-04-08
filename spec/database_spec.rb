require 'spec_helper'
require 'ashikawa-core/database'

describe Ashikawa::Core::Database do
  subject { Ashikawa::Core::Database }
  
  before :each do
    mock(Ashikawa::Core::Collection)
    mock(Ashikawa::Core::Connection)
    @address = 'http://localhost:8529'
  end
  
  it "should initialize with ip and port" do
    database = subject.new(@address)
    database.ip.should == "http://localhost"
    database.port.should == "8529"
  end
  
  describe "initialized database" do
    subject { Ashikawa::Core::Database.new @address }
    
    it "should fetch all available collections" do
      Ashikawa::Core::Connection.stub :request do |path|
        server_response("collections/all")
      end
      Ashikawa::Core::Connection.should_receive(:request).with("/collection")
      
      Ashikawa::Core::Collection.should_receive(:new).with(subject, "example_1", id: 4588)
      Ashikawa::Core::Collection.should_receive(:new).with(subject, "example_2", id: 4589)
      
      subject.collections.length.should == 2
    end
    
    it "should fetch a single collection if it exists" do
      Ashikawa::Core::Connection.stub :request do |path|
        server_response("collections/4588")
      end
      Ashikawa::Core::Connection.should_receive(:request).with("/collection/4588")
      
      Ashikawa::Core::Collection.should_receive(:new).with(subject, "example_1", id: 4588)
      
      subject[4588]
    end
    
    it "should create a single collection if it doesn't exist" do
      Ashikawa::Core::Connection.stub :request do |path, method = {}|
        if method.has_key? :post
          server_response("collections/4590")
        else
          server_response("collections/not_found")
        end
      end
      Ashikawa::Core::Connection.should_receive(:request).with("/collection/new_collection")
      Ashikawa::Core::Connection.should_receive(:request).with("/collection/new_collection", post: { name: "new_collection"} )
      
      Ashikawa::Core::Collection.should_receive(:new).with(subject, "new_collection", id: 4590)
      
      subject['new_collection']
    end
  end
end