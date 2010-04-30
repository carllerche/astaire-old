require 'helper'

describe "Astaire::DSL" do
  def build_app(&blk)
    @app = Rack::Lint.new(Class.new(Astaire::Base, &blk))
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