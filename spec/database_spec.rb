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
      stub_request(:get, "#{@address}/_api/collection").to_return body: server_response("collections/all"), header: {"Content-Type" => "application/json"}
      Ashikawa::Core::Collection.should_receive(:new).with("example_1")
      Ashikawa::Core::Collection.should_receive(:new).with("example_2")
      
      subject.collections.length.should == 2
    end
  end
end