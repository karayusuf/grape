module Grape
  class RouteSet

    def self.prepare(endpoint)
      new(endpoint).to_a
    end

    delegate :prepare_path, :compile_path, :namespace, to: '@endpoint'
    attr_reader :endpoint, :options, :settings

    def initialize(endpoint)
      @endpoint = endpoint
      @options  = endpoint.options
      @settings = endpoint.settings
    end

    def methods_and_paths
      options[:method].product(options[:path])
    end

    def anchor
      anchor = options[:route_options][:anchor]
      anchor.nil? ? true : anchor
    end

    def requirements
      endpoint_requirements = options[:route_options][:requirements] || {}
      all_requirements = (settings.gather(:namespace).map(&:requirements) << endpoint_requirements)
      requirements = all_requirements.reduce({}) do |base_requirements, single_requirements|
        base_requirements.merge!(single_requirements)
      end
    end

    def to_a
      methods_and_paths.map do |method, path|
        prepared_path = prepare_path(path)

        path = compile_path(prepared_path, anchor && !options[:app], requirements)
        regex = Rack::Mount::RegexpWithNamedGroups.new(path)
        path_params = {}
        # named parameters in the api path
        named_params = regex.named_captures.map { |nc| nc[0] } - [ 'version', 'format' ]
        named_params.each { |named_param| path_params[named_param] = "" }
        # route parameters declared via desc or appended to the api declaration
        route_params = (options[:route_options][:params] || {})
        path_params.merge!(route_params)
        request_method = (method.to_s.upcase unless method == :any)

        Route.new(options[:route_options].clone.merge({
          :prefix => settings[:root_prefix],
          :version => settings[:version] ? settings[:version].join('|') : nil,
          :namespace => namespace,
          :method => request_method,
          :path => prepared_path,
          :params => path_params,
          :compiled => path,
        }))

      end
    end
  end
end
