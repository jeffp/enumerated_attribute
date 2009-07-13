
begin
  # Load library
  require 'rubygems'
  
  gem 'activerecord', ENV['AR_VERSION'] ? "=#{ENV['AR_VERSION']}" : '>=2.1.0'
  require 'active_record'
  
  #FIXTURES_ROOT = File.dirname(__FILE__) + '/../../fixtures/'
  
  # Load TestCase helpers
  #require 'active_support/test_case'
  #require 'active_record/fixtures'
  #require 'active_record/test_case'
  
  # Establish database connection
  ActiveRecord::Base.establish_connection({'adapter' => 'sqlite3', 'database' => ':memory:'})
  ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/active_record.log")
	
	connection = ActiveRecord::Base.connection
	connection.create_table(:racers, :force=>true) do |t|
		t.string :name
		t.string :gear
	end
	
end
