require 'unit/spec_helper'
require 'ashikawa-core/document'

describe Ashikawa::Core::Document do
  let(:collection) { double() }
  let(:raw_data) {
    {
      "_id" => "1234567/2345678",
      "_rev" => "3456789",
      "first_name" => "The",
      "last_name" => "Dude"
    }
  }
  subject { Ashikawa::Core::Document }

  it "should initialize with correct data" do
    document = subject.new collection, raw_data
    document.id.should == 2345678
    document.revision.should == 3456789
  end

  describe "initialized document" do
    subject { Ashikawa::Core::Document.new collection, raw_data}

    it "should return the correct value for an existing attribute" do
      subject["first_name"].should be(raw_data["first_name"])
    end

    it "should return nil for an non-existing attribute" do
      subject["no_name"].should be_nil
    end

    it "should be deletable" do
      collection.should_receive(:send_request).with("document/#{raw_data['_id']}",
        { delete: {} }
      )
      collection.should_receive(:id).and_return(1234567)

      subject.delete
    end

    it "should store changes to the database" do
      collection.should_receive(:send_request).with("document/#{raw_data['_id']}",
        { put: { "first_name" => "The", "last_name" => "Other" } }
      )
      collection.should_receive(:id).and_return(1234567)

      subject["last_name"] = "Other"
      subject.save
    end

  end
end
