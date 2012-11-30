require "ashikawa-core/status"

describe Ashikawa::Core::Status do
  subject { Ashikawa::Core::Status }
  let(:status_codes) { (1..6).to_a }

  it "should know if the collection is new born" do
    status = subject.new 1
    status.new_born?.should == true

    (status_codes - [1]).each do |status_code|
      status = subject.new status_code
      status.new_born?.should == false
    end
  end

  it "should know if the collection is unloaded" do
    status = subject.new 2
    status.unloaded?.should == true

    (status_codes - [2]).each do |status_code|
      status = subject.new status_code
      status.unloaded?.should == false
    end
  end

  it "should know if the collection is loaded" do
    status = subject.new 3
    status.loaded?.should == true

    (status_codes - [3]).each do |status_code|
      status = subject.new status_code
      status.loaded?.should == false
    end
  end

  it "should know if the collection is being unloaded" do
    status = subject.new 4
    status.being_unloaded?.should == true

    (status_codes - [4]).each do |status_code|
      status = subject.new status_code
      status.being_unloaded?.should == false
    end
  end

  it "should know if the collection is corrupted" do
    status = subject.new 6
    status.corrupted?.should == true
  end
end
