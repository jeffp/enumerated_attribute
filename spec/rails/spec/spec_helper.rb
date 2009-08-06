# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)
#require 'enumerated_attribute'
require 'spec/autorun'
require 'spec/rails'
require 'webrat'
require 'matchers'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Webrat.configure do |config|
	config.mode = :rails
end
	
Spec::Runner.configure do |config|
end

#setup for integrating webrat with rspec
module Spec::Rails::Example
  class IntegrationExampleGroup < ActionController::IntegrationTest
    
    def initialize(defined_description, options={}, &implementation)
      defined_description.instance_eval do
        def to_s
          self
        end
      end
      super(defined_description)
    end
    
    Spec::Example::ExampleGroupFactory.register(:integration, self)
  end
end

