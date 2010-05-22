require 'rubygems'

gem 'activerecord', ENV['AR_VERSION'] ? "=#{ENV['AR_VERSION']}" : '>=2.1.0'
require 'active_record'
require 'active_support/core_ext/logger' rescue nil  # rails3

require 'enumerated_attribute'

ActiveRecord::Base.establish_connection({'adapter' => 'sqlite3', 'database' => ':memory:'})
ActiveRecord::Base.logger = Logger.new("#{File.dirname(__FILE__)}/active_record.log")

connection = ActiveRecord::Base.connection
  connection.create_table(:race_cars, :force=>true) do |t|
	t.string :name
	t.enum :gear
	t.enum :lights
  t.timestamps
end
connection.create_table(:bicycles, :force=>true) do |t|
	t.string :name
	t.enum :speed
	t.enum :gear
end
	
#basic_associations
connection.create_table(:companies, :force=>true) do |t|
	t.string :name
	t.string :status
end
connection.create_table(:contract_workers, :force=>true) do |t|
	t.references :company
	t.references :contractor
	t.string :status
end
connection.create_table(:licenses, :force=>true) do |t|
	t.references :company
	t.string :status
end
connection.create_table(:contractors, :force=>true) do |t|
	t.string :name
	t.string :status
end
connection.create_table(:employees, :force=>true) do |t|
	t.references :company
	t.string :name
	t.string :status
end

#polymorphic_associations
connection.create_table(:comments, :force=>true) do |t|
	t.references :document, :polymorphic=>true
	t.text :comment
	t.string :status
end
connection.create_table(:articles, :force=>true) do |t|
	t.string :name
	t.string :status
end
connection.create_table(:images, :force=>true) do |t|
	t.string :name
	t.string :status
end

#single table inheritance
connection.create_table(:sti_parents, :force=>true) do |t|
  t.string :type
  t.enum :parent_enum
  t.string :sub_nonenum
  t.enum :sub_enum
  t.timestamps
end
