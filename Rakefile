require "bundler"
Bundler.setup

gemspec = eval(File.read("rack-subdomain.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["rack-subdomain.gemspec"] do
  system "gem build rack-subdomain.gemspec"
  system "gem install rack-subdomain-#{Rack::Subdomain::VERSION}.gem"
end
