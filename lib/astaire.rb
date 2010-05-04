require 'active_support/concern'
require 'action_controller'
require 'astaire/railtie' if defined?(Rails)

module Astaire
  # Thanks Sinatra
  CALLERS_TO_IGNORE = [
    /\/astaire(\/(railtie))?\.rb$/, # all astaire code
    /lib\/tilt.*\.rb$/,    # all tilt code
    /\(.*\)/,              # generated code
    /custom_require\.rb$/, # rubygems require hacks
    /active_support/,      # active_support require hacks
  ]

  # add rubinius (and hopefully other VM impls) ignore patterns ...
  CALLERS_TO_IGNORE.concat(RUBY_IGNORE_CALLERS) if defined?(RUBY_IGNORE_CALLERS)

  class InlineTemplates < ActionView::PathResolver
    def initialize
      super
      @templates = {}
    end

    def add_controller(controller)
      file = caller_files.first

      begin
        app, data =
          ::IO.read(file).gsub("\r\n", "\n").split(/^__END__$/, 2)
      rescue Errno::ENOENT
        app, data = nil
      end

      if data
        lines = app.count("\n") + 1
        template = nil
        data.each_line do |line|
          lines += 1
          if line =~ /^@@\s*(.*)/
            template = ''
            @templates["#{controller.controller_path}/#{$1}"] =
              [template, file, lines]
          elsif template
            template << line
          end
        end
      end
    end

    def query(path, exts, formats)
      query = Regexp.escape(path)
      exts.each do |ext|
        query << '(' << ext.map {|e| e && Regexp.escape(".#{e}") }.join('|') << '|)'
      end

      templates = []
      @templates.select { |k,v| k =~ /^#{query}$/ }.each do |path, (source, file, lines)|
        handler, format = extract_handler_and_format(path, formats)
        templates << ActionView::Template.new(source, path, handler,
          :virtual_path => path, :format => format)
      end

      templates.sort_by {|t| -t.identifier.match(/^#{query}$/).captures.reject(&:blank?).size }
    end

    # Like Kernel#caller but excluding certain magic entries and without
    # line / method information; the resulting array contains filenames only.
    def caller_files
      caller_locations.
        map { |file,line| file }
    end

    def caller_locations
      caller(1).
        map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
        reject { |file,line| CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
    end
  end

  module DSL
    extend ActiveSupport::Concern

    include AbstractController::Helpers

    included do
      class_attribute :_astaire_router
      self._astaire_router = ActionDispatch::Routing::RouteSet.new

      class_attribute :_astaire_helpers
      self._astaire_helpers = url_helper_module

      class_attribute :_inline_resolver
      self._inline_resolver = InlineTemplates.new

      _inline_resolver.add_controller(self)

      include _astaire_helpers
      helper _astaire_helpers

      append_view_path _inline_resolver
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

      def inherited(klass)
        super
        _inline_resolver.add_controller(klass)
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