require 'active_support/concern'
require 'action_controller'
require 'astaire/railtie' if defined?(Rails)

module Astaire
  module DSL
    extend ActiveSupport::Concern

    include AbstractController::Helpers

    included do
      class_attribute :_astaire_router
      self._astaire_router = ActionDispatch::Routing::RouteSet.new

      class_attribute :_astaire_helpers
      self._astaire_helpers = url_helper_module

      include _astaire_helpers
      helper _astaire_helpers
    end

    module ClassMethods
      def call(env)
        _astaire_router.call(env)
      end

      def mapper
        @mapper ||= ActionDispatch::Routing::Mapper.new(_astaire_router)
      end

      %w(get post put delete).each do |method|
        class_eval <<-R, __FILE__, __LINE__+1
          def #{method}(path, opts = {}, &blk)
            map_astaire_action "#{method}", path, opts, blk
          end
        R
      end

    private

      def map_astaire_action(method, path, opts, blk)
        action_name = "[#{method}] #{path}"
        define_method action_name, &blk
        opts.merge! :via => method, :to => action(action_name)

        mapper.match(path, opts)
        make_url_helper(opts[:as]) if opts[:as]
      end

      def url_helper_module
        Module.new do
          def _astaire_url_opts_from_args(name, route, args, only_path)
            opts = args.extract_options!

            if args.any?
              opts[:_positional_args] = args
              opts[:_positional_keys] = route.segment_keys
            end

            opts = url_options.merge(opts)
            opts.merge!(:use_route => name, :only_path => only_path)

            if path_segments = opts[:_path_segments]
              path_segments.delete(:controller)
              path_segments.delete(:action)
            end

            opts
          end
        end
      end

      def make_url_helper(name)
        name   = name.to_sym
        router = _astaire_router

        _astaire_helpers.module_eval do
          define_method "#{name}_path" do |*args|
            route = router.named_routes[name]
            opts  = _astaire_url_opts_from_args(name, route, args, true)
            router.url_for(opts)
          end

          define_method "#{name}_url" do |*args|
            route = router.named_routes[name]
            opts  = _astaire_url_opts_from_args(name, route, args, false)
            router.url_for(opts)
          end
        end
      end
    end
  end
end