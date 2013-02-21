require 'acceptance/spec_helper'

describe "Indices" do
  let(:database) { Ashikawa::Core::Database.new ARANGO_HOST }
  subject { database["documenttest"] }
  let(:index) { subject.add_index :skiplist, :on => [:identifier] }

  it "should be possible to set indices" do
    pending "Updating to new ArangoDB version"

    index.delete

    expect {
      subject.add_index :skiplist, :on => [:identifier]
    }.to change { subject.indices.length }.by(1)
  end

  it "should be possible to get an index by ID" do
    pending "Updating to new ArangoDB version"

    subject.index(index.id).id.should == index.id
    subject.indices[0].class.should == Ashikawa::Core::Index
  end

  it "should be possible to remove indices" do
    pending "Delete doesn't work at random"

    expect {
      index.delete
    }.to change { subject.indices.length }.by(-1)
  end
end
