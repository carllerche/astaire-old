require 'helper'

describe "Astaire::DSL" do
  def build_app(&blk)
    app = Class.new(ActionController::Base) { include Astaire::DSL }
    app.class_eval(&blk)
    @app = Rack::Lint.new(app)
  end

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