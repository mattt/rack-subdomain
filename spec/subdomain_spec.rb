require 'rack/subdomain'

RSpec.describe Rack::Subdomain do
  it 'keeps the path and URI of overlapping requests independent' do
    exclusions = []
    allow(exclusions).to receive(:include?) do |subdomain|
      Fiber.yield if subdomain == 'alpha'
      false
    end

    app = lambda { |env| [200, {}, [env['PATH_INFO'], env['REQUEST_URI']]] }
    middleware = described_class.new(app, 'example.test', except: exclusions) do
      map 'alpha', to: '/users/:subdomain'
      map '*', to: '/sites/:subdomain'
    end

    alpha = {
      'HTTP_HOST' => 'alpha.example.test', 'SERVER_NAME' => 'alpha.example.test',
      'SERVER_PORT' => '80', 'rack.url_scheme' => 'http',
      'PATH_INFO' => '/one', 'QUERY_STRING' => ''
    }
    beta = {
      'HTTP_HOST' => 'beta.example.test', 'SERVER_NAME' => 'beta.example.test',
      'SERVER_PORT' => '8443', 'rack.url_scheme' => 'https',
      'PATH_INFO' => '/two', 'QUERY_STRING' => 'page=2'
    }

    first_request = Fiber.new { middleware.call(alpha) }
    first_request.resume
    beta_response = middleware.call(beta)
    alpha_response = first_request.resume

    expect(alpha_response).to eq([200, {}, [
      '/users/alpha/one', 'http://alpha.example.test/users/alpha/one'
    ]])
    expect(beta_response).to eq([200, {}, [
      '/sites/beta/two', 'https://beta.example.test:8443/sites/beta/two?page=2'
    ]])
  end
end
