require 'spec/car'

#used to test that method_missing chaining plays nice in inheritance situation

describe "Car" do
  
  it "should not hit Car method_missing when calling dynamic state method :gear_is_in_reverse?" do
    c = Car.new
    c.gear_is_in_reverse?
    c.car_method_hit.should be_false
    c.vehicle_method_hit.should be_false
  end
  
  it "should hit Car and Vehicle method_missing when not calling supported dynamic state method" do
    c = Car.new
    c.parking_break_is_on?
    c.car_method_hit.should be_true
    c.vehicle_method_hit.should be_true
  end
    
end
