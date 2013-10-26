require 'ipaddress'

module Rack
  class Subdomain
    def initialize(app, domain, options = {}, &block)

      @options = prepare_options(options)
      @app = app
      @domain = domain
      @mappings = {}

      if @options[:to]
        map('*', @options[:to])
      elsif block_given?
        instance_eval &block
      else
        raise ArgumentError, "missing `:to` option or block to define mapping"
      end
    end

    def call(env)
      @env = env
      @subdomain = subdomain

      # NOTE: it is OK if @subdomain is an empty string here (as that is the no subdomain case)
      if @subdomain && domain_match? && constraint_match?(@subdomain, @options)
        pattern, route = @mappings.detect do |pattern, route|
          pattern === subdomain
        end

        if route
          remap_with_substituted_path!(route.gsub(/\:subdomain/, @subdomain))
        end
      end

      @app.call(env)
    end

    def map(pattern, route)
      map(pattern, route[:to]) and return if route.kind_of?(Hash)
      raise ArgumentError, "missing route" unless route

      pattern = /.*/ if pattern == '*'
      regexp = Regexp.new(pattern)
      @mappings[regexp] = route
    end

  private

    def eval_domain
      case @domain
      when Proc
        @domain.call(@env['HTTP_HOST'])
      when Regexp
        @domain.match(@env['HTTP_HOST'])
      else
        @domain
      end
    end

    def subdomain
      @env['HTTP_HOST'].sub(/\.?#{eval_domain}.*$/,'') unless @env['HTTP_HOST'].match(/^localhost/) or IPAddress.valid?(@env['SERVER_NAME'])
    end

    def remap_with_substituted_path!(path)
      scheme = @env["rack.url_scheme"]
      # next two lines are dangerous as they can potentially mutate host and port?
      host = "#{@subdomain}.#{eval_domain}"
      port = ":#{@env['SERVER_PORT']}" unless @env['SERVER_PORT'] == '80'
      path = @env["PATH_INFO"] = ::File.join(path, @env["PATH_INFO"])
      query_string = "?" + @env["QUERY_STRING"] unless @env["QUERY_STRING"].empty?
      @env["REQUEST_URI"] = "#{scheme}://#{host}#{port}#{path}#{query_string}"
    end

    def prepare_options(options)
      options = {to: options} if options.is_a?(String) # backwards compatibility
      options = {except: ['', 'www']}.merge(options)
      options[:except] = Array(options[:except])
      options[:only]   = Array(options[:only]) if options[:only]
      options
    end

    def domain_match?
      case @domain
      when String then !/#{@domain}$/.match(@env['HTTP_HOST']).nil?
      else !!eval_domain
      end
    end

    def constraint_match?(subdomain, options)
      if options[:only]
        options[:only].include?(subdomain)
      else
        !options[:except].include?(subdomain)
      end
    end
  end
end
