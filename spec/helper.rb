$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'astaire'
require 'rack/test'

class Astaire::Base < ActionController::Base
  include Astaire::DSL
end

Spec::Runner.configure do
  include Rack::Test::Methods

  def app
    @app
  end
end