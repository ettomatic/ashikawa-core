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
  
  # describe "an initialized collection" do
  #   
  # end
end