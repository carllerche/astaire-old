$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'astaire'
require 'rack/test'

describe "Astaire::DSL" do
  include Rack::Test::Methods

  attr_reader :app

  def build_app(&blk)
    @app = Rack::Lint.new(Class.new(Astaire::Base, &blk))
  end

  class Astaire::Base < ActionController::Base
    include Astaire::DSL
  end

  describe "basic DSL usage" do
    describe "get '/'" do
      before :each do
        build_app do
          get "/" do
            render :text => "Hello"
          end
        end
      end

      it "returns the test" do
        get "/"
        last_response.body.should == "Hello"
      end
      
      it "returns a 404 when using other methods" do
        post "/"
        last_response.status.should == 404
      end
    end
  end
end