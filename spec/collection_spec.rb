require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Collection }
  
  it "should have a name" do
    my_collection = subject.new "my_name"
    my_collection.name.should == "my_name"
  end
  
  it "should accept an ID" do
    my_collection = subject.new "my_name", id: 12345
    my_collection.id.should == 12345
  end
  
  # describe "an initialized collection" do
  #   
  # end
end