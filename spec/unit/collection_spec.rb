require 'unit/spec_helper'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Collection }

  before :each do
    @database = double()
  end

  it "should have a name" do
    my_collection = subject.new @database, server_response("collections/60768679")
    my_collection.name.should == "example_1"
  end

  it "should accept an ID" do
    my_collection = subject.new @database, server_response("collections/60768679")
    my_collection.id.should == "60768679"
  end

  it "should create a query" do
    collection = subject.new @database, server_response("collections/60768679")

    mock Ashikawa::Core::Query
    Ashikawa::Core::Query.stub(:new)
    Ashikawa::Core::Query.should_receive(:new).exactly(1).times.with(collection)

    collection.query
  end

  describe "attributes of a collection" do
    it "should check if the collection waits for sync" do
      @database.stub(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties") }
      @database.should_receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new @database, { "id" => "60768679" }
      my_collection.wait_for_sync?.should be_true
    end

    it "should know how many documents the collection has" do
      @database.stub(:send_request).with("collection/60768679/count", {}).and_return { server_response("collections/60768679-count") }
      @database.should_receive(:send_request).with("collection/60768679/count", {})

      my_collection = subject.new @database, { "id" => "60768679" }
      my_collection.length.should == 54
    end

    it "should know if the collection is volatile" do
      @database.stub(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties-volatile") }
      @database.should_receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new(@database, { "id" => "60768679" })
      my_collection.volatile?.should == true
    end

    it "should know if the collection is not volatile" do
      @database.stub(:send_request).with("collection/60768679/properties", {}).and_return { server_response("collections/60768679-properties") }
      @database.should_receive(:send_request).with("collection/60768679/properties", {})

      my_collection = subject.new(@database, { "id" => "60768679" })
      my_collection.volatile?.should == false
    end

    it "should check for the figures" do
      @database.stub(:send_request).with("collection/60768679/figures", {}).and_return { server_response("collections/60768679-figures") }
      @database.should_receive(:send_request).with("collection/60768679/figures", {}).at_least(1).times

      mock Ashikawa::Core::Figure
      Ashikawa::Core::Figure.stub(:new)
      Ashikawa::Core::Figure.should_receive(:new).exactly(1).times.with(server_response("collections/60768679-figures")["figures"])

      my_collection = subject.new @database, { "id" => "60768679" }
      my_collection.figure
    end
  end

  describe "an initialized collection" do
    subject { Ashikawa::Core::Collection.new @database, { "id" => "60768679", "name" => "example_1" } }

    it "should get deleted" do
      @database.stub(:send_request).with("collection/60768679/", :delete => {})
      @database.should_receive(:send_request).with("collection/60768679/", :delete => {})

      subject.delete
    end

    it "should get loaded" do
      @database.stub(:send_request).with("collection/60768679/load", :put => {})
      @database.should_receive(:send_request).with("collection/60768679/load", :put => {})

      subject.load
    end

    it "should get unloaded" do
      @database.stub(:send_request).with("collection/60768679/unload", :put => {})
      @database.should_receive(:send_request).with("collection/60768679/unload", :put => {})

      subject.unload
    end

    it "should get truncated" do
      @database.stub(:send_request).with("collection/60768679/truncate", :put => {})
      @database.should_receive(:send_request).with("collection/60768679/truncate", :put => {})

      subject.truncate!
    end

    it "should change if it waits for sync" do
      @database.stub(:send_request).with("collection/60768679/properties", :put => {"waitForSync" => true})
      @database.should_receive(:send_request).with("collection/60768679/properties", :put => {"waitForSync" => true})

      subject.wait_for_sync = true
    end

    it "should change its name" do
      @database.stub(:send_request).with("collection/60768679/rename", :put => {"name" => "my_new_name"})
      @database.should_receive(:send_request).with("collection/60768679/rename", :put => {"name" => "my_new_name"})

      subject.name = "my_new_name"
    end

    describe "add and get single documents" do
      it "should receive a document by ID" do
        @database.stub(:send_request).with("document/60768679/333").and_return { server_response('documents/example_1-137249191') }
        @database.should_receive(:send_request).with("document/60768679/333")

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject[333]
      end

      it "should replace a document by ID" do
        @database.stub(:send_request).with("document/60768679/333", :put => {"name" => "The Dude"})
        @database.should_receive(:send_request).with("document/60768679/333", :put => {"name" => "The Dude"})

        subject[333] = {"name" => "The Dude"}
      end

      it "should create a new document" do
        @database.stub(:send_request).with("document?collection=60768679", :post => { "name" => "The Dude" }).and_return do
          server_response('documents/new-example_1-137249191')
        end
        @database.stub(:send_request).with("document/60768679/333", :post => { "name" => "The Dude" }).and_return { server_response('documents/example_1-137249191') }

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject.create({"name" => "The Dude"})
      end

      it "should create a new document with `<<`" do
        @database.stub(:send_request).with("document?collection=60768679", :post => { "name" => "The Dude" }).and_return do
          server_response('documents/example_1-137249191')
        end
        @database.stub(:send_request).with("document/60768679/333").and_return { server_response('documents/example_1-137249191') }

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject << {"name" => "The Dude"}
      end

      describe "indices" do
        it "should add a new index" do
          @database.stub(:send_request).with("index?collection=60768679", :post => {
            "type" => "hash", "fields" => [ "a", "b" ]
          }).and_return { server_response('indices/new-hash-index') }
          @database.should_receive(:send_request).with("index?collection=60768679", :post => {
            "type" => "hash", "fields" => [ "a", "b" ]
          })

          Ashikawa::Core::Index.should_receive(:new).with(subject,
            server_response('indices/new-hash-index'))

          subject.add_index :hash, :on => [ :a, :b ]
        end

        it "should get an index by ID" do
          @database.stub(:send_request).with(
            "index/example_1/168054969"
          ).and_return { server_response('indices/hash-index') }

          Ashikawa::Core::Index.should_receive(:new).with(subject,
            server_response('indices/hash-index'))

          subject.index 168054969
        end

        it "should get all indices" do
          @database.stub(:send_request).with(
            "index?collection=60768679"
          ).and_return { server_response('indices/all') }

          Ashikawa::Core::Index.should_receive(:new).exactly(1).times

          indices = subject.indices
          indices.length.should == 1
        end
      end
    end
  end
end
