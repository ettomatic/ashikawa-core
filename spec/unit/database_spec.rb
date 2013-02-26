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

  it "should create a query" do
    database = subject.new @connection

    mock Ashikawa::Core::Query
    Ashikawa::Core::Query.stub(:new)
    Ashikawa::Core::Query.should_receive(:new).exactly(1).times.with(database)

    database.query
  end

  describe "initialized database" do
    subject { Ashikawa::Core::Database.new @connection }

    it "should delegate authentication to the connection" do
      @connection.should_receive(:authenticate_with).with({ :username => "user", :password => "password" })

      subject.authenticate_with :username => "user", :password => "password"
    end

    it "should fetch all available collections" do
      @connection.stub(:send_request) {|path| server_response("collections/all") }
      @connection.should_receive(:send_request).with("collection")

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/all")["collections"][0])
      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/all")["collections"][1])

      subject.collections.length.should == 2
    end

    it "should create a non volatile collection by default" do
      @connection.stub(:send_request) { |path| server_response("collections/60768679") }
      @connection.should_receive(:send_request).with("collection",
        :post => { :name => "volatile_collection"})

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection")
    end

    it "should create a volatile collection when asked" do
      @connection.stub(:send_request) { |path| server_response("collections/60768679") }
      @connection.should_receive(:send_request).with("collection",
        :post => { :name => "volatile_collection", :isVolatile => true})

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection", :is_volatile => true)
    end

    it "should create an edge collection when asked" do
      @connection.stub(:send_request) { |path| server_response("collections/60768679") }
      @connection.should_receive(:send_request).with("collection",
        :post => { :name => "volatile_collection", :type => 3})

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject.create_collection("volatile_collection", :content_type => :edge)
    end

    it "should fetch a single collection if it exists" do
      @connection.stub(:send_request) { |path| server_response("collections/60768679") }
      @connection.should_receive(:send_request).with("collection/60768679")

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject.collection(60768679)
    end

    it "should fetch a single collection with the array syntax" do
      @connection.stub(:send_request) { |path| server_response("collections/60768679") }
      @connection.should_receive(:send_request).with("collection/60768679")

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject[60768679]
    end

    it "should create a single collection if it doesn't exist" do
      @connection.stub :send_request do |path, method|
        method ||= {}
        if method.has_key? :post
          server_response("collections/60768679")
        else
          raise Ashikawa::Core::CollectionNotFoundException
        end
      end
      @connection.should_receive(:send_request).with("collection/new_collection")
      @connection.should_receive(:send_request).with("collection", :post => { :name => "new_collection"} )

      Ashikawa::Core::Collection.should_receive(:new).with(subject, server_response("collections/60768679"))

      subject['new_collection']
    end

    it "should send a request via the connection object" do
      @connection.should_receive(:send_request).with("my/path", :post => { :data => "mydata" })

      subject.send_request "my/path", :post => { :data => "mydata" }
    end
  end
end
