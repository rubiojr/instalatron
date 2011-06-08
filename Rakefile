require 'rubygems'
require 'bundler'
require 'lib/instalatron.rb'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.version = Instalatron::VERSION
  gem.name = "instalatron"
  gem.homepage = "http://github.com/abiquo/instalatron"
  gem.license = "MIT"
  gem.summary = %Q{Abiquo Installer Testing Framework}
  gem.description = %Q{Tests graphical installers using VirtualBox, keyboard driven input and image recognition technics}
  gem.email = "srubio@abiquo.com"
  gem.authors = ["Sergio Rubio"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'mixlib-cli', '>= 1.2'
  gem.add_runtime_dependency 'mixlib-cli', '>= 1.2'
  gem.add_runtime_dependency 'virtualbox', '>= 0.8'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

