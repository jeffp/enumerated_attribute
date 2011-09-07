# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
#require 'enumerated_attribute'
require 'spec/autorun'
gem 'rspec-rails', '>= 1.3.2'
require 'spec/rails'
gem 'webrat', '>= 0.7.1'
require 'webrat'
require 'matchers'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Webrat.configure do |config|
	config.mode = :rails
end
	
RSpec::Runner.configure do |config|
end

#setup for integrating webrat with rspec
module RSpec::Rails::Example
  class IntegrationExampleGroup < ActionController::IntegrationTest
    
    def initialize(defined_description, options={}, &implementation)
      defined_description.instance_eval do
        def to_s
          self
        end
      end
      super(defined_description)
    end
    
    RSpec::Example::ExampleGroupFactory.register(:integration, self)
  end
end

