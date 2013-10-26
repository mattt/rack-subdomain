class App

  def initialize
    @app = Rack::Builder.new do

      # Map all subdomains
      use Rack::Subdomain, 'example1.com', to: '/users/:subdomain'

      # Nested mapping with :except condition
      use Rack::Subdomain, 'example2.com', except: ['', 'www', 'secure'] do
        map 'downloads', to: '/downloads'
        map '*', to: '/users/:subdomain'
      end

      # :to mapping with :only condition
      use Rack::Subdomain, 'example3.com', only: ['', 'www'], to: '/nested'

      map '/' do
        run App.respond('in root')
      end

      map '/www' do
        run App.respond('in www')
      end

      map '/downloads' do
        run App.respond('in downloads')
      end

      map '/users' do
        run App.respond('in users')
      end

      map '/users/foo' do
        run App.respond('in users/foo')
      end

      map '/secure' do
        run App.respond('in nested')
      end

      map '/nested' do
        run App.respond('in nested')
      end

      #run App.run
    end
  end

  def call(env)
    @app.call(env)
  end

  def self.respond(msg)
    Proc.new {|env| [200, {'Content-Type' => 'text/html'}, [msg]] }
  end
end
