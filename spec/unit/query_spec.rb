require 'unit/spec_helper'
require 'ashikawa-core/query'

describe Ashikawa::Core::Query do
  let(:collection) { double }

  describe "initialized with collection" do
    subject { Ashikawa::Core::Query.new collection: collection }

    before { collection.stub(:name).and_return "example_1" }

    describe "get all" do
      it "should list all documents" do
        collection.stub(:send_request).with("/simple/all",
          put: {"collection" => "example_1"}
        ).and_return { server_response('simple-queries/all') }
        collection.should_receive(:send_request).with("/simple/all", put: {"collection" => "example_1"})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.all
      end

      it "should be able to limit the number of documents" do
        collection.stub(:send_request).with("/simple/all", put: {"collection" => "example_1", "limit" => 1}).and_return { server_response('simple-queries/all_skip') }
        collection.should_receive(:send_request).with("/simple/all", put: {"collection" => "example_1", "limit" => 1})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.all limit: 1
      end

      it "should be able to skip documents" do
        collection.stub(:send_request).with("/simple/all", put: {"collection" => "example_1", "skip" => 1}).and_return { server_response('simple-queries/all_limit') }
        collection.should_receive(:send_request).with("/simple/all", put: {"collection" => "example_1", "skip" => 1})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.all skip: 1
      end
    end

    describe "first by example" do
      let(:example) { {:hello => "world"} }

      it "should find exactly one fitting document" do
        collection.stub(:database).and_return { double }

        collection.stub(:send_request).with("/simple/first-example", put:
          {"collection" => "example_1", "example" => { :hello => "world"}}
        ).and_return { server_response('simple-queries/example') }
        collection.should_receive(:send_request).with("/simple/first-example", put:
          {"collection" => "example_1", "example" => { :hello => "world"}})

        Ashikawa::Core::Document.should_receive(:new)

        subject.first_example example
      end
    end

    describe "all by example" do
      let(:example) { {:hello => "world"} }

      it "should find all fitting documents" do
        collection.stub(:send_request).with("/simple/by-example", put:
          {"collection" => "example_1", "example" => { :hello => "world"}}
        ).and_return { server_response('simple-queries/example') }
        collection.should_receive(:send_request).with("/simple/by-example", put:
          {"collection" => "example_1", "example" => { :hello => "world"}})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.by_example example
      end

      it "should be able to limit the number of documents" do
        collection.stub(:send_request).with("/simple/by-example", put: {"collection" => "example_1", "limit" => 2, "example" => { :hello => "world"}}).and_return { server_response('simple-queries/example') }
        collection.should_receive(:send_request).with("/simple/by-example", put: {"collection" => "example_1", "limit" => 2, "example" => { :hello => "world"}})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.by_example example, limit: 2
      end

      it "should be able to skip documents" do
        collection.stub(:send_request).with("/simple/by-example", put:
          {"collection" => "example_1", "skip" => 1, "example" => { :hello => "world"}}
        ).and_return { server_response('simple-queries/example') }
        collection.should_receive(:send_request).with("/simple/by-example", put:
          {"collection" => "example_1", "skip" => 1, "example" => { :hello => "world"}})

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.by_example example, skip: 1
      end
    end

    describe "near a geolocation" do
      it "should find documents based on latitude/longitude" do
        collection.stub(:send_request).with("/simple/near", put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0 }).and_return { server_response('simple-queries/near') }
        collection.should_receive(:send_request).with("/simple/near", put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0 })

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.near latitude: 0, longitude: 0
      end
    end

    describe "within a radious of a geolocation" do
      it "should look for documents based on latidude/longitude" do
        collection.stub(:send_request).with("/simple/within", put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0, "radius" => 2 }).and_return { server_response('simple-queries/within') }
        collection.should_receive(:send_request).with("/simple/within" , put: { "collection" => "example_1", "latitude" => 0, "longitude" => 0, "radius" => 2 })

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.within latitude: 0, longitude: 0, radius: 2
      end
    end

    describe "in a certain range" do
      it "should look for documents with an attribute in that range" do
        arguments = { "collection" => "example_1", "attribute" => "age", "left" => 50, "right" => 60, "closed" => false}
        collection.stub(:send_request).with("/simple/range", put: arguments).and_return { server_response('simple-queries/range') }
        collection.should_receive(:send_request).with("/simple/range" , put: arguments)

        Ashikawa::Core::Cursor.should_receive(:new)

        subject.in_range attribute: "age", left: 50, right: 60, closed: false
      end
    end
  end
end
