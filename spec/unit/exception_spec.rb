require "ashikawa-core/exceptions/document_not_found"
require "ashikawa-core/exceptions/no_collection_provided"

describe Ashikawa::Core::DocumentNotFoundException do
  it "should have a good explanation" do
    subject.to_s.should include "does not exist"
  end
end

describe Ashikawa::Core::NoCollectionProvidedException do
  it "should have a good explanation" do
    subject.to_s.should include "without a collection"
  end
end
