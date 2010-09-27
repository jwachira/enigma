require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Enigma do
  
  class TestApp < Sinatra::Base
    get '/' do
      signature = request.env["HTTP_" + Enigma::SIGNATURE_HEADER]
      method    = request.request_method.downcase
      path      = request.path
      payload   = request.body.read

      if Enigma.matches?(signature, method, path, payload)
        status 200
      else
        status 403
      end
    end
  end

  def app
    @app ||= TestApp.new
  end

  def client
    @client ||= Enigma::Spec::RackTestClient.new(app)
  end

  describe "with correct authentication" do
    it "should be successful" do
      response = client.execute(
        :method  => :get,
        :path    => "/",
        :headers => {"X_ENIGMA_SIGNATURE" => Enigma.signature('get', '/', '')}
      )

      response.code.should == 200
    end
  end

  describe "with incorrect authentication" do
    it "should be forbidden" do
      response = client.execute(
        :method  => :get,
        :path    => "/",
        :headers => {"X_ENIGMA_SIGNATURE" => "h4x0r"}
      )

      response.code.should == 403
    end
  end

  describe "with empty authorization" do
    it "should be forbidden" do
      response = client.execute(
        :method => :get,
        :path => "/",
        :headers => {})

      response.code.should == 403
    end
  end
end
