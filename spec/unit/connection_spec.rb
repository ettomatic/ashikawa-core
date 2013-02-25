require 'unit/spec_helper'
require 'ashikawa-core/connection'

describe Ashikawa::Core::Connection do
  let(:address) { "http://localhost:8529" }
  subject { Ashikawa::Core::Connection }

  it "should have a scheme, hostname and port" do
    connection = subject.new address

    connection.scheme.should == "http"
    connection.host.should == "localhost"
    connection.port.should == 8529
  end

  it "should default to HTTP, localhost and ArangoDB port" do
    connection = subject.new address

    connection.scheme.should == "http"
    connection.host.should == "localhost"
    connection.port.should == 8529
  end

  describe "initialized connection" do
    let(:request_stub) { Faraday::Adapter::Test::Stubs.new }
    subject { Ashikawa::Core::Connection.new(address, [:test, request_stub]) }

    it "should send a get request" do
      request_stub.get("/_api/my/path") do
        [200, {}, { "name" => "dude" }]
      end

      subject.send_request "my/path"

      request_stub.verify_stubbed_calls
    end

    it "should send a post request" do
      request_stub.post("/_api/my/path") do |request|
        request[:body].should == "{\"name\":\"new_collection\"}"
        [200, {}, { "name" => "dude" }]
      end

      subject.send_request "my/path", :post => { :name => 'new_collection' }

      request_stub.verify_stubbed_calls
    end

    it "should send a put request" do
      request_stub.put("/_api/my/path") do |request|
        request[:body].should == '{"name":"new_collection"}'
        [200, {}, { "name" => "dude" }]
      end

      subject.send_request "my/path", :put => { :name => 'new_collection' }

      request_stub.verify_stubbed_calls
    end

    it "should send a delete request" do
      request_stub.delete("/_api/my/path") do |request|
        [200, {}, { "name" => "dude" }]
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

    it "should parse JSON" do
      request_stub.get("/_api/my/path") do
        [200, {}, { "name" => "dude" }]
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
  end
end
