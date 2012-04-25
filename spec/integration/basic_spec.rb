require 'integration/spec_helper'

describe "Basics" do
  subject { "http://localhost:8529" }
  
  it "should have booted up an AvocadoDB instance" do
    expect { JSON.parse RestClient.get(subject) }.to raise_error(RestClient::NotImplemented)
  end
  
  it "should do what the README describes" do
    database = Ashikawa::Core::Database.new "http://localhost:8529"
    
    database["my_collection"]
    database["my_collection"].name = "new_name"
    database["new_name"].delete
  end
end