require 'enumerated_attribute'

#used to test that method_missing chaining plays nice in inheritance situations

class Vehicle
  
  attr_accessor :vehicle_method_hit
  
  def initialize
    @vehicle_method_hit = false
  end
  
  def method_missing(methId, *args)
    @vehicle_method_hit = true
    #end here
  end
  
  alias :vmh :vehicle_method_hit

end

class Car < Vehicle  
  attr_accessor :car_method_hit
  
  def initialize
    super
    @car_method_hit = false
  end
  
  def method_missing(methId, *args)
    @car_method_hit = true
    super
  end
  
  enum_attr :gear, %w(reverse ^neutral drive)  
  alias :cmt :car_method_hit
end
