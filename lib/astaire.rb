require 'active_support/concern'
require 'action_controller'

module Astaire
  module DSL
    extend ActiveSupport::Concern

    included do
      unless respond_to?(:_router)
        def self._router
          @_router ||= ActionDispatch::Routing::RouteSet.new
        end
      end
    end

    module ClassMethods
      def call(env)
        _router.call(env)
      rescue ActionController::RoutingError
        [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, []]
      end

      def mapper
        @mapper ||= ActionDispatch::Routing::Mapper.new(_router)
      end

      %w(get post put delete).each do |method|
        class_eval <<-R, __FILE__, __LINE__+1
          def #{method}(path, opts = {}, &blk)
            action_name = "[#{method}] \#{path}"
            define_method action_name, &blk
            mapper.match(path, :via => '#{method}', :to => action(action_name))
          end
        R
      end
    end
  end
end