require 'spec_helper'
require 'ashikawa-core/connection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Connection }
  
  it "should have an IP and port" do
    connection = Ashikawa::Core::Connection.new "http://localhost:8529"
    
    connection.ip.should == "http://localhost"
    connection.port.should == 8529
  end
  
  describe "initialized connection" do
    subject { Ashikawa::Core::Connection.new "http://localhost:8529" }
    
    it "should send a get request" do
      stub_request(:get, "http://localhost:8529/my/path").to_return body: "{ \"name\": \"dude\" }"
      
      subject.send_request "/my/path"
      
      WebMock.should have_requested(:get, "http://localhost:8529/my/path")
    end
    
    it "should send a post request" do
      stub_request(:post, "http://localhost:8529/my/path").with(:body => {"name"=>"new_collection"}).to_return body: "{ \"name\": \"dude\" }"
      
      subject.send_request "/my/path", post: { :name => 'new_collection' }
      
      WebMock.should have_requested(:post, "http://localhost:8529/my/path").with :body => {"name"=>"new_collection"}
    end
    
    it "should parse JSON" do
      stub_request(:get, "http://localhost:8529/my/path").to_return body: "{ \"name\": \"dude\" }"
      
      subject.send_request("/my/path").should == {"name" => "dude"}
    end
  end
end
