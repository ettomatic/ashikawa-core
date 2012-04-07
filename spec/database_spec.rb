require 'spec_helper'
require 'ashikawa-core/database'

describe Ashikawa::Core::Database do
  subject { Ashikawa::Core::Database }
  
  before :each do
    mock(Ashikawa::Core::Collection)
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
      stub_request(:get, "#{@address}/_api/collection").to_return body: server_response("collections/all")
      
      Ashikawa::Core::Collection.should_receive(:new).with("example_1", id: 4588)
      Ashikawa::Core::Collection.should_receive(:new).with("example_2", id: 4589)
      
      subject.collections.length.should == 2
      
      WebMock.should have_requested :get, "#{@address}/_api/collection"
    end
    
    it "should fetch a single collection" do
      stub_request(:get, "#{@address}/_api/collection/4588").to_return body: server_response("collections/4588")
      Ashikawa::Core::Collection.should_receive(:new).with("example_1", id: 4588)
      
      subject['4588']
      
      WebMock.should have_requested :get, "#{@address}/_api/collection/4588"
    end
  end
end