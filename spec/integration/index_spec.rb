require 'integration/spec_helper'

describe "Indices" do
  subject { Ashikawa::Core::Database.new ARANGO_HOST }

  describe "setting and deleting indices" do
    before :each do
      @collection = subject["documenttests"]
      @collection.truncate!
    end

    it "should be possible to set indices" do
      @collection.add_index :geo, on: [:latitude, :longitude]
      @collection.add_index :skiplist, on: [:identifier]
      @collection.indices.length.should == 3 # primary index is always set
      @collection.indices[0].class.should == Ashikawa::Core::Index
    end

    it "should be possible to get an index by ID" do
      index = @collection.add_index :skiplist, on: [:identifier]
      @collection.index(index.id).id.should == index.id
    end

    it "should be possible to remove indices" do
      expect {
        index = @collection.add_index :skiplist, on: [:identifier]
        index.delete
      }.to change { @collection.indices.length }.by(-1)
    end
  end
end
