require 'unit/spec_helper'
require 'ashikawa-core/collection'

describe Ashikawa::Core::Collection do
  subject { Ashikawa::Core::Collection }

  before :each do
    @database = double()
  end

  it "should have a name" do
    my_collection = subject.new @database, server_response("/collections/4588")
    my_collection.name.should == "example_1"
  end

  it "should accept an ID" do
    my_collection = subject.new @database, server_response("/collections/4588")
    my_collection.id.should == 4588
  end

  it "should create a query" do
    collection = subject.new @database, server_response("/collections/4588")

    mock Ashikawa::Core::Query
    Ashikawa::Core::Query.stub(:new)
    Ashikawa::Core::Query.should_receive(:new).exactly(1).times.with(collection)

    collection.query
  end

  describe "attributes of a collection" do
    it "should check if the collection waits for sync" do
      @database.stub(:send_request).with("/collection/4590/properties", {}).and_return { server_response("/collections/4590") }
      @database.should_receive(:send_request).with("/collection/4590/properties", {})

      my_collection = subject.new @database, { "id" => "4590" }
      my_collection.wait_for_sync?.should be_true
    end

    it "should know how many documents the collection has" do
      @database.stub(:send_request).with("/collection/4590/count", {}).and_return { server_response("/collections/4590-properties") }
      @database.should_receive(:send_request).with("/collection/4590/count", {})

      my_collection = subject.new @database, { "id" => "4590" }
      my_collection.length.should == 54
    end

    it "should check for the figures" do
      @database.stub(:send_request).with("/collection/73482/figures", {}).and_return { server_response("/collections/73482-figures") }
      @database.should_receive(:send_request).with("/collection/73482/figures", {}).at_least(1).times

      mock Ashikawa::Core::Figure
      Ashikawa::Core::Figure.stub(:new)
      Ashikawa::Core::Figure.should_receive(:new).exactly(1).times.with(server_response("/collections/73482-figures")["figures"])

      my_collection = subject.new @database, { "id" => "73482" }
      my_collection.figure
    end
  end

  describe "an initialized collection" do
    subject { Ashikawa::Core::Collection.new @database, { "id" => "4590", "name" => "example_1" } }

    it "should get deleted" do
      @database.stub(:send_request).with("/collection/4590", delete: {})
      @database.should_receive(:send_request).with("/collection/4590", delete: {})

      subject.delete
    end

    it "should get loaded" do
      @database.stub(:send_request).with("/collection/4590/load", put: {})
      @database.should_receive(:send_request).with("/collection/4590/load", put: {})

      subject.load
    end

    it "should get unloaded" do
      @database.stub(:send_request).with("/collection/4590/unload", put: {})
      @database.should_receive(:send_request).with("/collection/4590/unload", put: {})

      subject.unload
    end

    it "should get truncated" do
      @database.stub(:send_request).with("/collection/4590/truncate", put: {})
      @database.should_receive(:send_request).with("/collection/4590/truncate", put: {})

      subject.truncate!
    end

    it "should change if it waits for sync" do
      @database.stub(:send_request).with("/collection/4590/properties", put: {"waitForSync" => true})
      @database.should_receive(:send_request).with("/collection/4590/properties", put: {"waitForSync" => true})

      subject.wait_for_sync = true
    end

    it "should change its name" do
      @database.stub(:send_request).with("/collection/4590/rename", put: {"name" => "my_new_name"})
      @database.should_receive(:send_request).with("/collection/4590/rename", put: {"name" => "my_new_name"})

      subject.name = "my_new_name"
    end

    describe "add and get single documents" do
      it "should receive a document by ID" do
        @database.stub(:send_request).with("/document/4590/333").and_return { server_response('documents/4590-333') }
        @database.should_receive(:send_request).with("/document/4590/333")

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject[333]
      end

      it "should replace a document by ID" do
        @database.stub(:send_request).with("/document/4590/333", put: {"name" => "The Dude"})
        @database.should_receive(:send_request).with("/document/4590/333", put: {"name" => "The Dude"})

        subject[333] = {"name" => "The Dude"}
      end

      it "should create a new document" do
        @database.stub(:send_request).with("/document?collection=4590", post: { "name" => "The Dude" }).and_return do
          server_response('documents/new-4590-333')
        end
        @database.stub(:send_request).with("/document/4590/333", post: { "name" => "The Dude" }).and_return { server_response('documents/4590-333') }

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject.create({"name" => "The Dude"})
      end

      it "should create a new document with `<<`" do
        @database.stub(:send_request).with("/document?collection=4590", post: { "name" => "The Dude" }).and_return do
          server_response('documents/new-4590-333')
        end
        @database.stub(:send_request).with("/document/4590/333").and_return { server_response('documents/4590-333') }

        # Documents need to get initialized:
        Ashikawa::Core::Document.should_receive(:new)

        subject << {"name" => "The Dude"}
      end

      describe "indices" do
        it "should add a new index" do
          @database.stub(:send_request).with("/index?collection=4590", post: {
            "type" => "hash", "fields" => [ "a", "b" ]
          }).and_return { server_response('indices/new-hash-index') }
          @database.should_receive(:send_request).with("/index?collection=4590", post: {
            "type" => "hash", "fields" => [ "a", "b" ]
          })

          Ashikawa::Core::Index.should_receive(:new).with(subject,
            server_response('indices/new-hash-index'))

          subject.add_index :hash, on: [ :a, :b ]
        end

        it "should get an index by ID" do
          @database.stub(:send_request).with(
            "/index/4590/168054969"
          ).and_return { server_response('indices/hash-index') }

          Ashikawa::Core::Index.should_receive(:new).with(subject,
            server_response('indices/hash-index'))

          subject.index 168054969
        end

        it "should get all indices" do
          @database.stub(:send_request).with(
            "/index?collection=4590"
          ).and_return { server_response('indices/all') }

          Ashikawa::Core::Index.should_receive(:new).exactly(1).times

          indices = subject.indices
          indices.length.should == 1
        end
      end
    end
  end
end
