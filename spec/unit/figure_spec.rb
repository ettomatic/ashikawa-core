require "ashikawa-core/figure"

describe Ashikawa::Core::Figure do
  let(:raw_figures) {
    {
      "datafiles" => {
        "count" => 1
      },
      "alive" => {
        "size" => 0,
        "count" => 0
      },
      "dead" => {
        "size" => 2384,
        "count" => 149
      }
    }
  }
  subject { Ashikawa::Core::Figure.new raw_figures }

  it "should check for the figures" do
    subject.datafiles_count.should == 1
    subject.alive_size.should == 0
    subject.alive_count.should == 0
    subject.dead_size.should == 2384
    subject.dead_count.should == 149
  end
end
