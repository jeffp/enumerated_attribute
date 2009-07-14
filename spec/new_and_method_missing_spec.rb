require 'car'

#used to test that method_missing chaining plays nice in inheritance situation

describe "CarWithMethods" do
	
	it "should initialize Car and Vehicle _method_missing_called? to false" do
		c= CarWithMethods.new
		c.car_method_missing_called?.should be_false
		c.vehicle_method_missing_called?.should be_false
	end
	
	it "should initialize Car and Vehicle _new_called? to false" do
		CarWithMethods.reset
		CarWithMethods.car_new_called?.should be_false
		CarWithMethods.vehicle_new_called?.should be_false
	end
	
	it "should initialize :gear to :neutral" do
		c = CarWithMethods.new
		c.gear.should == :neutral
	end
	
	it "should hit both new methods for Car and Vehicle on instantiation" do
		CarWithMethods.reset
		CarWithMethods.new
		CarWithMethods.car_new_called?.should be_true
		CarWithMethods.vehicle_new_called?.should be_true
	end
  
  it "should not hit method_missing when calling dynamic predicate method :gear_is_in_reverse?" do
    c = CarWithMethods.new
    c.gear_is_in_reverse?
    c.car_method_missing_called?.should be_false
    c.vehicle_method_missing_called?.should be_false
  end
  
  it "should hit Car and Vehicle method_missing when calling unsupported dynamic predicate method" do
    c = CarWithMethods.new
    c.parking_break_is_on?
    c.car_method_missing_called?.should be_true
    c.vehicle_method_missing_called?.should be_true
  end
end

describe "CarWithoutMethods" do
	
	it "should set Car and Vehicle _new_called? to false when calling :reset" do
		CarWithoutMethods.reset
		CarWithoutMethods.car_new_called?.should be_false
		CarWithoutMethods.vehicle_new_called?.should be_false
	end
	
	it "should hit only Vehicle _new_called? on instantiation" do
		CarWithoutMethods.reset
		CarWithoutMethods.new
		CarWithoutMethods.car_new_called?.should be_false
		CarWithoutMethods.vehicle_new_called?.should be_true
	end
		
	it "should not hit Vehicle method_missing when calling dynamic predicate method :gear_is_in_first?" do
		c = CarWithoutMethods.new		
		c.gear_is_in_drive?
		c.vehicle_method_missing_called?.should be_false
	end
	
	it "should hit Vehicle method_missing when calling unsupported predicate method" do
		c = CarWithoutMethods.new
		c.parking_break2_is_on?
		c.vehicle_method_missing_called?.should be_true
	end	
    
end
