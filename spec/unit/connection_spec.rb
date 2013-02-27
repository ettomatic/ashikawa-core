require 'unit/spec_helper'
require 'ashikawa-core/connection'

describe Ashikawa::Core::Connection do
  let(:request_stub) { Faraday::Adapter::Test::Stubs.new }
  subject { Ashikawa::Core::Connection.new(ARANGO_HOST, :adapter => [:test, request_stub]) }

  it "should have a scheme, hostname and port" do
    subject.scheme.should == "http"
    subject.host.should == "localhost"
    subject.port.should == 8529
  end

  it "should send a get request" do
    request_stub.get("/_api/my/path") do
      [200, {}, MultiJson.dump({ "name" => "dude" })]
    end

    subject.send_request "my/path"

    request_stub.verify_stubbed_calls
  end

  it "should send a post request" do
    request_stub.post("/_api/my/path") do |request|
      request[:body].should == "{\"name\":\"new_collection\"}"
      [200, {}, MultiJson.dump({ "name" => "dude" })]
    end

    subject.send_request "my/path", :post => { :name => 'new_collection' }

    request_stub.verify_stubbed_calls
  end

  it "should send a put request" do
    request_stub.put("/_api/my/path") do |request|
      request[:body].should == '{"name":"new_collection"}'
      [200, {}, MultiJson.dump({ "name" => "dude" })]
    end

    subject.send_request "my/path", :put => { :name => 'new_collection' }

    request_stub.verify_stubbed_calls
  end

  it "should send a delete request" do
    request_stub.delete("/_api/my/path") do |request|
      [200, {}, MultiJson.dump({ "name" => "dude" })]
    end

    subject.send_request "my/path", :delete => { }

    request_stub.verify_stubbed_calls
  end

  it "should throw its own exception when doing a bad request" do
    request_stub.get("/_api/bad/request") do
      raise Faraday::Error::ClientError.new(RuntimeError)
    end

    expect do
      subject.send_request("bad/request")
    end.to raise_error(Ashikawa::Core::BadRequest)

    request_stub.verify_stubbed_calls
  end

  it "should write JSON request" do
    request_stub.post("/_api/my/path") do |req|
      req[:body].should == "{\"test\":1}"
      [200, {}, MultiJson.dump({ "name" => "dude" })]
    end

    subject.send_request("my/path", :post => { "test" => 1})
    request_stub.verify_stubbed_calls
  end

  it "should parse JSON response" do
    request_stub.get("/_api/my/path") do
      [200, {}, "{\"name\":\"dude\"}"]
    end

    subject.send_request("my/path").should == {"name" => "dude"}
    request_stub.verify_stubbed_calls
  end

  describe "authentication" do
    it "should authenticate with username and password" do
      subject.authenticate_with :username => "testuser", :password => "testpassword"

      subject.username.should == "testuser"
      subject.password.should == "testpassword"
    end

    it "should have authentication turned off by default" do
      subject.authentication?.should be_false
    end

    it "should tell if authentication is enabled" do
      subject.authenticate_with :username => "testuser", :password => "testpassword"
      subject.authentication?.should be_true
    end

    it "should only accept a username & password pairs" do
      expect {
        subject.authenticate_with :username => "kitty"
      }.to raise_error(ArgumentError)

      expect {
        subject.authenticate_with :password => "cheezburger?"
      }.to raise_error(ArgumentError)
    end

    it "should allow chaining" do
      subject.authenticate_with(:username => "a", :password => "b").should == subject
    end

    it "should send the authentication data with every GET request" do
      pending "Find out how to check for basic auth via Faraday Stubs"

      request_stub.get("/_api/my/path") do |request|
        [200, {}, { "name" => "dude" }]
      end

      subject.authenticate_with :username => "user", :password => "pass"
      subject.send_request "my/path"

      request_stub.verify_stubbed_calls
    end
  end

  describe "exception handling" do
    it "should raise an exception if a document is not found" do
      request_stub.get("/_api/document/4590/333") do
        raise Faraday::Error::ResourceNotFound.new(RuntimeError)
      end

      expect { subject.send_request "document/4590/333" }.to raise_error(Ashikawa::Core::DocumentNotFoundException)

      request_stub.verify_stubbed_calls
    end

    it "should raise an exception if a collection is not found" do
      request_stub.get("/_api/collection/4590") do
        raise Faraday::Error::ResourceNotFound.new(RuntimeError)
      end

      expect { subject.send_request "collection/4590" }.to raise_error(Ashikawa::Core::CollectionNotFoundException)

      request_stub.verify_stubbed_calls
    end

    it "should raise an exception if an index is not found" do
      request_stub.get("/_api/index/4590/333") do
        raise Faraday::Error::ResourceNotFound.new(RuntimeError)
      end

      expect { subject.send_request "index/4590/333" }.to raise_error(Ashikawa::Core::IndexNotFoundException)

      request_stub.verify_stubbed_calls
    end

    it "should raise an exception for unknown pathes" do
      request_stub.get("/_api/unknown_path/4590/333") do
        raise Faraday::Error::ResourceNotFound.new(RuntimeError)
      end

      expect { subject.send_request "unknown_path/4590/333" }.to raise_error(Ashikawa::Core::UnknownPath)

      request_stub.verify_stubbed_calls
    end
  end

  describe "logging" do
    let(:request_stub) { Faraday::Adapter::Test::Stubs.new }
    let(:logger) { double }
    subject {
      Ashikawa::Core::Connection.new(ARANGO_HOST, :adapter => [:test, request_stub], :logger => logger)
    }

    it "should log a get request" do
      request_stub.get("/_api/test") do
        [200, {}, MultiJson.dump({:a => 1})]
      end
      logger.should_receive(:info).with("GET #{ARANGO_HOST}/_api/test ")
      logger.should_receive(:info).with("200 {\"a\":1}")
      subject.send_request("test")
    end

    it "should log a post request" do
      pending "This fails on 1.8.7 for unknown reasons. Will investigate." if RUBY_VERSION == "1.8.7"

      request_stub.post("/_api/test") do
        [201, {}, MultiJson.dump({:b => 2})]
      end
      logger.should_receive(:info).with("POST #{ARANGO_HOST}/_api/test {:a=>2}")
      logger.should_receive(:info).with("201 {\"b\":2}")
      subject.send_request("test", :post => { :a => 2})
    end
  end
end
