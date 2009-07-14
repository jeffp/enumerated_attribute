require 'test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'race_car'

describe "RaceCar" do
	
	it "should initialize according to enumerated attribute definitions" do
		r = RaceCar.new
		r.gear.should == :neutral
		r.choke.should == :none
	end
	
	it "should create new instance using block" do
		r = RaceCar.new do |r|
			r.gear = :first
			r.choke = :medium
			r.lights = 'on'
		end
		r.gear.should == :first
		r.lights.should == 'on'
		r.choke.should == :medium
	end
	
	it "should initialize using parameter hash" do
		r=RaceCar.new(:name=>'FastFurious', :gear=>:second, :lights=>'on', :choke=>:medium)
		r.gear.should == :second
		r.lights.should == 'on'
		r.choke.should == :medium
	end
	
	it "should convert enumerated attributes from string to symbols" do
	end
	
	it "should not convert non-enumerated column attributes from string to symbols" do
	end	

	it "should raise InvalidEnumeration when parametrically initialized with :gear=>:drive" do
		r=RaceCar.new
		lambda{ r.gear= :drive}.should raise_error(EnumeratedAttribute::InvalidEnumeration)
	end
	
	it "should raise InvalidEnumeration when parametrically initialized with :choke=>:all" do
		r=RaceCar.new
		lambda{ r.choke= :all}.should raise_error(EnumeratedAttribute::InvalidEnumeration)
	end
	
	it "should return non-column enumerated attributes from [] method" do
		r = RaceCar.new
		r[:choke].should == :none
	end
	
	it "should return enumerated column attributes from [] method" do
		r=RaceCar.new
		r.gear = :neutral
		r[:gear].should == :neutral
	end
	
	it "should set non-column enumerated attributes with []= method" do
		r=RaceCar.new
		r[:choke] = :medium
		r.choke.should == :medium
	end
	
	it "should set enumerated column attriubtes with []= method" do
		r=RaceCar.new
		r[:gear] = :second
		r.gear.should == :second
	end
	
	it "should raise InvalidEnumeration when setting enumerated column attribute with []= method" do
		r=RaceCar.new
		lambda{ r[:gear]= :drive }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
	end
	
	it "should set and retrieve string for non-enumerated column attributes with []=" do
		r=RaceCar.new
		r[:lights] = 'on'
		r.lights.should == 'on'
		r[:lights].should == 'on'
	end
	
	it "should set and retrieve symbol for non-enumerated column attributes with []=" do
		r=RaceCar.new
		r[:lights] = :on
		r.lights.should == :on
		r[:lights].should == :on
	end
	
	
	it "should provide symbol values for enumerated column attributes from the :attributes method" do
	end
	
	it "should provide normal values for non-enumerated column attributes from the :attributes method" do
	end
	
	it "should raise ArgumentError when setting invalid enumertion value with :attributes= method" do
	end

	it "should save and retrieve its name" do
		r = RaceCar.new
		r.name= 'Green Meanie'
		r.save!
		
		s = RaceCar.find r.id
		s.should_not be_nil
		s.name.should == 'Green Meanie'
	end
	
	it "should save and retrieve symbols for enumerated column attribute" do
		r = RaceCar.new
		r.gear = :over_drive
		r.save!
		
		s = RaceCar.find r.id
		#s.should_not be_nil
		s.gear.should == :over_drive
	end
	
	it "should not save values for enumerated attribute" do
	end
	
	it "should save string and retrieve string for non-enumerated column attributes" do
		r =RaceCar.new
		r.lights = 'on'
		r.save!
		
		s = RaceCar.find r.id
		s.lights.should == 'on'
		s[:lights].should == 'on'
	end
	
	it "should save symbol and retrieve string for non-enumerated column attributes" do
		r =RaceCar.new
		r.lights = :off
		r.save!
		
		s = RaceCar.find r.id
		s.lights.should == "--- :off\n"
		s[:lights].should == "--- :off\n"
	end
	
end
