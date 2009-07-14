
require 'rubygems'

gem 'activerecord', ENV['AR_VERSION'] ? "=#{ENV['AR_VERSION']}" : '>=2.1.0'
require 'active_record'

ActiveRecord::Base.establish_connection({'adapter' => 'sqlite3', 'database' => ':memory:'})
ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/active_record.log")

connection = ActiveRecord::Base.connection
connection.create_table(:race_cars, :force=>true) do |t|
	t.string :name
	t.string :gear
	t.string :lights
end
connection.create_table(:bicycles, :force=>true) do |t|
	t.string :name
	t.string :speed
	t.string :gear
end
	
