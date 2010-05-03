module Astaire
  class Rails < Rails::Railtie
    config.to_prepare do
      ApplicationController.class_eval { include Astaire::DSL }
    end

    initializer "astaire.cascade_routing" do |app|
      # A lambda is needed here to ensure that the constant is reloaded
      # after each request (in development mode)
      astaire_app = proc { |env| ApplicationController.call(env) }
      app.middleware.use ActionDispatch::Cascade, lambda { astaire_app }
    end

    # Controllers must be preloaded in order for Astaire's routing
    # to be hooked up
    initializer "astaire.preload_controllers" do |app|
      config.to_prepare do
        app.config.paths.app.controllers.each do |load_path|
          matcher = /\A#{Regexp.escape(load_path)}\/(.*)\.rb\Z/
          Dir["#{load_path}/**/*_controller.rb"].each do |file|
            require_dependency file.sub(matcher, '\1')
          end
        end
      end
    end
  end
end