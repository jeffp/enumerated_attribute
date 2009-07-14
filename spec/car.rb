require 'enumerated_attribute'

#used to test that method_missing chaining plays nice in inheritance situations

class Vehicle  
  def vehicle_method_missing_called?; @vehicle_method_missing_called; end
	def self.vehicle_new_called?; @@vehicle_new_called; end
	def self.reset; @@vehicle_new_called = false; end
	
	@@vehicle_new_called = false  
  def initialize
    @vehicle_method_missing_called = false
		super
  end
  
  def method_missing(methId, *args)
    @vehicle_method_missing_called = true
    #end here
  end
	
	def self.new
		@@vehicle_new_called = true
		super
	end
  
end

class CarWithMethods < Vehicle  
  def car_method_missing_called?; @car_method_missing_called; end
	def self.car_new_called?; @@car_new_called; end
	def self.reset; @@car_new_called = false; super; end

	def self.new 
		@@car_new_called = true
		super
	end
	
  def method_missing(methId, *args)
    @car_method_missing_called = true
    super
  end		

  enum_attr :gear, %w(reverse ^neutral drive)  

	@@car_new_called = false  
  def initialize
    @car_method_missing_called = false
    super
  end
  
end

class CarWithoutMethods < Vehicle
  def car_method_missing_called?; @car_method_missing_called; end
	def self.car_new_called?; @@car_new_called; end
	def self.reset; @@car_new_called = false; super; end
  
  enum_attr :gear, %w(reverse ^neutral drive)  

	@@car_new_called = false  
  def initialize
    @car_method_missing_called = false
    super
  end
  
end
	
