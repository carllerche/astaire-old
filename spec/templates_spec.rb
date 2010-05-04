require 'helper'

describe "Inline templates" do
  class MyController < ActionController::Base
    include Astaire::DSL

    get "/hello" do
      render :index
    end
  end

  class MyOtherController < ActionController::Base
    include Astaire::DSL

    get "/word" do
      render :foo
    end
  end

  class SubclassController < MyOtherController
    get "/what" do
      render :index
    end
  end

  it "is able to find inline templates" do
    @app = Rack::Lint.new(MyController)
    get "/hello"
    last_response.body.should == "Hello World\n\n"
  end

  it "is able to have multiple controllers per file" do
    @app = Rack::Lint.new(MyOtherController)
    get "/word"
    last_response.body.should == "OMG HI!"
  end

  it "works with subclasses of Astaire controllers" do
    @app = Rack::Lint.new(SubclassController)
    get "/what"
    last_response.body.should == "Hello World\n\n"
  end
end

__END__

@@ index.html.erb
Hello <%= 'World' %>

@@ foo.html.erb
OMG HI!