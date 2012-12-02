require 'unit/spec_helper'
require 'ashikawa-core/connection'

describe Ashikawa::Core::Connection do
  subject { Ashikawa::Core::Connection }

  it "should have a scheme, hostname and port" do
    connection = subject.new "http://localhost:8529"

    connection.scheme.should == "http"
    connection.host.should == "localhost"
    connection.port.should == 8529
  end

  it "should default to HTTP, localhost and ArangoDB port" do
    connection = subject.new

    connection.scheme.should == "http"
    connection.host.should == "localhost"
    connection.port.should == 8529
  end

  describe "initialized connection" do
    subject { Ashikawa::Core::Connection.new "http://localhost:8529" }

    it "should send a get request" do
      stub_request(:get, "http://localhost:8529/_api/my/path").to_return body: '{ "name": "dude" }'

      subject.send_request "/my/path"

      WebMock.should have_requested(:get, "http://localhost:8529/_api/my/path")
    end

    it "should send a post request" do
      stub_request(:post, "http://localhost:8529/_api/my/path").with(:body => '{"name":"new_collection"}').to_return body: '{ "name": "dude" }'

      subject.send_request "/my/path", post: { :name => 'new_collection' }

      WebMock.should have_requested(:post, "http://localhost:8529/_api/my/path").with :body => '{"name":"new_collection"}'
    end

    it "should send a put request" do
      stub_request(:put, "http://localhost:8529/_api/my/path").with(:body => '{"name":"new_collection"}').to_return body: '{ "name": "dude" }'

      subject.send_request "/my/path", put: { :name => 'new_collection' }

      WebMock.should have_requested(:put, "http://localhost:8529/_api/my/path").with :body => '{"name":"new_collection"}'
    end

    it "should send a delete request" do
      stub_request(:delete, "http://localhost:8529/_api/my/path").to_return body: '{ "name": "dude" }'

      subject.send_request "/my/path", delete: { }

      WebMock.should have_requested(:delete, "http://localhost:8529/_api/my/path")
    end

    it "should parse JSON" do
      stub_request(:get, "http://localhost:8529/_api/my/path").to_return body: '{ "name": "dude" }'

      subject.send_request("/my/path").should == {"name" => "dude"}
    end
  end

  describe "authentication" do
    subject { Ashikawa::Core::Connection.new }

    it "should authenticate with username and password" do
      subject.authenticate_with username: "testuser", password: "testpassword"

      subject.username.should == "testuser"
      subject.password.should == "testpassword"
    end

    it "should have authentication turned off by default" do
      subject.authentication?.should be_false
    end

    it "should tell if authentication is enabled" do
      subject.authenticate_with username: "testuser", password: "testpassword"
      subject.authentication?.should be_true
    end

    it "should only accept a username & password pairs" do
      expect {
        subject.authenticate_with username: "kitty"
      }.to raise_error(ArgumentError)

      expect {
        subject.authenticate_with password: "cheezburger?"
      }.to raise_error(ArgumentError)
    end

    it "should allow chaining" do
      subject.authenticate_with(username: "a", password: "b").should == subject
    end

    it "should send the authentication data with every GET request" do
      stub_request(:get, "http://user:pass@localhost:8529/_api/my/path").to_return body: '{ "name": "dude" }'

      subject.authenticate_with username: "user", password: "pass"
      subject.send_request "/my/path"

      WebMock.should have_requested(:get, "http://user:pass@localhost:8529/_api/my/path")
    end
  end

  describe "exception handling" do
    subject { Ashikawa::Core::Connection.new }

    it "should raise an exception if a document is not found" do
      stub_request(:get, "http://localhost:8529/_api/document/4590/333").to_return do
        raise RestClient::ResourceNotFound
      end
      expect { subject.send_request "/document/4590/333" }.to raise_error(Ashikawa::Core::DocumentNotFoundException)
    end

    it "should raise an exception if a collection is not found" do
      stub_request(:get, "http://localhost:8529/_api/collection/4590").to_return do
        raise RestClient::ResourceNotFound
      end
      expect { subject.send_request "/collection/4590" }.to raise_error(Ashikawa::Core::CollectionNotFoundException)
    end

    it "should raise an exception for unknown pathes" do
      stub_request(:get, "http://localhost:8529/_api/unknown_path/4590/333").to_return do
        raise RestClient::ResourceNotFound
      end
      expect { subject.send_request "/unknown_path/4590/333" }.to raise_error(Ashikawa::Core::UnknownPath)
    end
  end
end
