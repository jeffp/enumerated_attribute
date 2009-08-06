require 'enumerated_attribute'

class Tractor
  
  GEAR_ENUM_VALUES = %w(reverse neutral first second over_drive).map{|v| v.to_sym}
  LIGHTS_ENUM_VALUES = %w(off low high).map{|v| v.to_sym}
  SIDE_LIGHT_ENUM_VALUES = [:off,:low,:high,:super_high]
  
  attr_accessor :name
  
  def initialize
    @name = 'old faithful'
  end
  
  enumerated_attribute :gear, %w(reverse ^neutral first second over_drive), :nil=>false do
    parked? is :neutral 
    driving? is [:first, :second, :over_drive]
    not_parked? is_not :neutral
    not_driving? is_not [:first, :second, :over_drive]
    upshift { self.gear_is_in_over_drive? ? self.gear : self.gear_next }
    downshift { self.driving? ? self.gear_previous : self.gear }
  end
	
	enum_attr :pto, %w(reverse ^off forward)
  
  enum_attr :plow, %w(^up down), :nil=>true do
    plowing? { self.gear_is_in_first? && self.plow == :down }
  end
  
  enum_attr :lights, LIGHTS_ENUM_VALUES, :plural=>:lights_enums, :init=>:off, :decrementor=>:turn_lights_down, :incrementor=>:turn_lights_up do
    lights_are_on? [:low, :high]
    lights_are_not_on? :off
  end
  
  enum_attr :side_light, %w(off low high super_high) do
    init :off
    enums_accessor :side_light_enums
    incrementor :side_light_up
    decrementor :side_light_down    
		label :off=>'OFF'
		labels :low => 'LOW DIM', :high => 'HIGH BEAM'
		labels :super_high => 'SUPER BEAM'
  end
  
  #enum_attr_reader :temperature, %w(low med high)
  #enum_attr_writer :ignition, %w(^off activate)
    
end
