require 'active_support/concern'
require 'action_controller'

module Astaire
  module DSL
    extend ActiveSupport::Concern

    module ClassMethods
      def call(env)
        finalize!
        router.call(env)
      rescue ActionController::RoutingError
        [404, {'Content-Type' => 'text/html', 'X-Cascade' => 'pass'}, []]
      end

      def finalize!
        return if @finalized
        router.finalize!
        @finalized = true
      end

      def router
        @router ||= begin
          rs = ActionDispatch::Routing::RouteSet.new
          rs.clear!
          rs
        end
      end

      def mapper
        @mapper ||= ActionDispatch::Routing::Mapper.new(router)
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