require 'integration/spec_helper'

describe "Basics" do
  subject { "http://localhost:8529" }
  
  it "should have booted up an AvocadoDB instance" do
    expect { JSON.parse RestClient.get(subject) }.to raise_error(RestClient::NotImplemented)
  end
end