$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'astaire'

class OmgController < ActionController::Base
  include Astaire::DSL

  view_paths << File.expand_path('../views', __FILE__)

  before_filter :puts_something

  get "/goodbye" do
    render :text => "goodbye"
  end

  get "/hello" do
    render :hello
  end

private

  def puts_something
    puts "Something"
  end

end

run OmgController