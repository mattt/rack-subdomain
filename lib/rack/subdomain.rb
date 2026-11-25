require 'ipaddress'

module Rack
  class Subdomain
    def initialize(app, domain, options = {}, &block)
      # Maintain compatibility with previous rack-subdomain gem
      options = {to: options} if options.is_a? String

      @options = {except: ['', 'www']}.merge(options)

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
      subdomain = subdomain_for(env)

      if subdomain && !subdomain.empty? && !@options[:except].include?(subdomain)
        pattern, route = @mappings.detect do |pattern, route|
          pattern === subdomain_for(env)
        end

        if route
          remap_with_substituted_path!(env, subdomain, route.gsub(/\:subdomain/, subdomain))
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

    def domain(env)
      case @domain
      when Proc
        @domain.call(env['HTTP_HOST'])
      when Regexp
        @domain.match(env['HTTP_HOST'])
      else
        @domain
      end
    end

    def subdomain_for(env)
      host = env['HTTP_HOST']
      return if host.nil? || host.match(/^localhost/) || IPAddress.valid?(env['SERVER_NAME'])

      host.sub(/\.?#{domain(env)}.*$/,'')
    end

    def remap_with_substituted_path!(env, subdomain, path)
      scheme = env["rack.url_scheme"]
      host = "#{subdomain}.#{domain(env)}"
      port = ":#{env['SERVER_PORT']}" unless env['SERVER_PORT'] == '80'
      path = env["PATH_INFO"] = ::File.join(path, env["PATH_INFO"])
      query_string = "?" + env["QUERY_STRING"] unless env["QUERY_STRING"].empty?

      env["REQUEST_URI"] = "#{scheme}://#{host}#{port}#{path}#{query_string}"
    end
  end
end
