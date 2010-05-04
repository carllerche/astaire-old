## Astaire: The basic Sinatra DSL for your Rails 3 apps

Astaire allows the use of the basic Sinatra get / post / put / delete
DSL inside of Rails controllers. This allows defining quick actions without
having to update config/routes.rb. For example:

    class ContactController < ActionController::Base

      get "/contact" do
        render :contact_form
      end

      post "/contact" do
        # handle form input
        redirect_to homepage_path
      end

    end

### Installation

Add the following to your application's Gemfile

    gem "astaire"

Then, run `bundle install` and you are good to go.

### Usage

Currently, Astaire provides 4 class level methods available in  the
controller: `#get`, `#post`, `#put`, and `#delete`. With these methods
you can define actions and routes all at once.

    class MyController < ActionController::Base

        # Get the contact form
        get "/contact" do
          render :contact_form
        end

        # The paths can also have named parameters and
        # optional segments
        #
        # /say/hello       => "I say: hello"
        # /say/hello/world => "I say: hello world"
        #
        get "/say/:one(/:two)" do
          words = [params[:one], params[:two]].compact.join(' ')
          render :text => "I say: #{words}"
        end
    end

It is possible to name actions such that regular URL helpers can generate them.

    class MyController < ActionController::Base

      # Will output /hello
      def index
        render :text => hello_path
      end

      get "/hello", :as => :hello do
        render :text => "hello"
      end

    end

Astaire supports inline templates in the same style as Sinatra. For example:

    class MyController < ActionController::Base

      get "/hello" do
        render :greetings
      end

    end

    __END__

    @@ greetings.html.erb
    Greetings to you.

### TODO

I guess, at this point I'm just putting what I have into the wild. Next
steps will be determined by feedback that I get.