require 'unit/spec_helper'
require 'ashikawa-core/database'

describe Ashikawa::Core::Database do
  subject { Ashikawa::Core::Database }

  before :each do
    mock(Ashikawa::Core::Connection)
    mock(Ashikawa::Core::Collection)
    mock(Ashikawa::Core::Cursor)
    @connection = double()
  end

  it "should initialize with a connection" do
    @connection.stub(:host) { "localhost" }
    @connection.stub(:port) { 8529 }

    database = subject.new @connection
    database.host.should == "localhost"
    database.port.should == 8529
  end

  it "should initialize with a connection string" do
    Ashikawa::Core::Connection.stub(:new).with("http://localhost:8529").and_return(double())
    Ashikawa::Core::Connection.should_receive(:new).with("http://localhost:8529")

    database = subject.new "http://localhost:8529"
  end

  describe "initialized database" do
    subject { Ashikawa::Core::Database.new @connection }

    it "should delegate authentication to the connection" do
      @connection.should_receive(:authenticate_with).with({ username: "user", password: "password" })

      subject.authenticate_with username: "user", password: "password"
    end

    it "should fetch all available collections" do
      @connection.stub(:send_request) {|path| server_response("collections/all") }
      @connection.should_receive(:send_request).with("/collection")

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("/collections/all")["collections"][0])
      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("/collections/all")["collections"][1])

      subject.collections.length.should == 2
    end

    it "should fetch a single collection if it exists" do
      @connection.stub(:send_request) { |path| server_response("collections/4588") }
      @connection.should_receive(:send_request).with("/collection/4588")

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("/collections/4588"))

      subject[4588]
    end

    it "should create a single collection if it doesn't exist" do
      @connection.stub :send_request do |path, method = {}|
        if method.has_key? :post
          server_response("collections/4590")
        else
          raise RestClient::ResourceNotFound
        end
      end
      @connection.should_receive(:send_request).with("/collection/new_collection")
      @connection.should_receive(:send_request).with("/collection", post: { name: "new_collection"} )

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/4590"))

      subject['new_collection']
    end

    it "should send a request via the connection object" do
      @connection.should_receive(:send_request).with("/my/path", post: { data: "mydata" })

      subject.send_request "/my/path", post: { data: "mydata" }
    end

    describe "handling queries" do
      it "should send a query to the server" do
        @connection.stub(:send_request).and_return { server_response("cursor/query") }
        @connection.should_receive(:send_request).with("/cursor", post: {
          query: "FOR u IN users LIMIT 2 RETURN u",
          count: true,
          batchSize: 2
        })
        Ashikawa::Core::Cursor.should_receive(:new).with(subject, server_response("cursor/query"))

        subject.query "FOR u IN users LIMIT 2 RETURN u", count: true, batch_size: 2
      end
    end
  end
end
