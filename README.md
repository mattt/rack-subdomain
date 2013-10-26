# rack-subdomain

[![Build Status](https://secure.travis-ci.org/mattt/rack-subdomain.png?branch=master)](http://travis-ci.org/mattt/rack-subdomain)
[![Code Climate](https://codeclimate.com/github/mattt/rack-subdomain.png)](https://codeclimate.com/github/mattt/rack-subdomain)

Rack middleware to transparently route requests with a subdomain to a specified path with substitutions. 

## Usage

### Gemfile

``` ruby
gem 'rack-subdomain'
```

### config.ru

``` ruby
# Map all subdomains
use Rack::Subdomain, "example.com", to: "/users/:subdomain"

# Nested mapping with :except condition
use Rack::Subdomain, "example.com", except: ['', 'www', 'secure'] do
  map 'downloads', to: "/downloads"
  map '*', to: "/users/:subdomain"
end

# :to mapping with :only condition
use Rack::Subdomain, "example.com", only: ['', 'www'], to: '/nested'
```

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

rack-subdomain is available under the MIT license. See the LICENSE file for more info.
