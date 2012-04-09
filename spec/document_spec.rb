require 'spec_helper'
require 'ashikawa-core/document'

describe Ashikawa::Core::Document do
  subject { Ashikawa::Core::Document }
    
  it "should initialize with an id and revision" do 
    document = subject.new "189990/1631782", 1631782
    document.id.should == "189990/1631782"
    document.revision.should == 1631782
  end
  
end
