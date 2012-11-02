require 'acceptance_auth/spec_helper'

describe "authenticated database" do
  subject { ARANGO_HOST }

  it "should have booted up an ArangoDB instance" do
    expect { RestClient.get(subject) }.to raise_error RestClient::Unauthorized
  end

  context "authentication" do
    subject { Ashikawa::Core::Database.new ARANGO_HOST }

    context "without user and password" do
      it "should not allow access to DB" do
        expect do
          subject["new_collection"]
        end.to raise_error RestClient::Unauthorized
      end
    end

    context "with user and password" do
      it "should allow acces to DB" do
        subject.authenticate_with username: 'testuser', password: 'testpassword'

        expect do
          subject["new_collection"]
          subject["new_collection"].delete
        end.to_not raise_error
      end

      it "should deny acces if username and password are wrong" do
        subject.authenticate_with username: 'ruffy', password: 'three_headed_monkey'

        expect do
          subject["denied"]
        end.to raise_error RestClient::Unauthorized
      end
    end
  end
end
