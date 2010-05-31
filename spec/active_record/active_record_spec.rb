require 'test_in_memory'
require 'active_record'
require 'enumerated_attribute'
require 'race_car'

describe "RaceCar" do

	it "should have default labels for :gear attribute" do
		labels_hash = {:reverse=>'Reverse', :neutral=>'Neutral', :first=>'First', :second=>'Second', :over_drive=>'Over drive'}
		labels = ['Reverse', 'Neutral', 'First', 'Second', 'Over drive']
		select_options = [['Reverse', 'reverse'], ['Neutral', 'neutral'], ['First', 'first'], ['Second', 'second'], ['Over drive', 'over_drive']]
		r=RaceCar.new
		r.gears.labels.should == labels
		labels_hash.each do |k,v|
			r.gears.label(k).should == v
		end
		r.gears.hash.should == labels_hash
		r.gears.select_options.should == select_options
	end
	
	it "should retrieve :gear enums through enums method" do
		r=RaceCar.new
		r.enums(:gear).should == r.gears
	end

	it "should return a Symbol type from reader methods" do
		r=RaceCar.new
		r.gear.should be_an_instance_of(Symbol)
	end
	
	it "should increment and decrement :gear attribute correctly" do
		r=RaceCar.new
		r.gear = :neutral
		r.gear_next.should == :first
		r.gear_next.should == :second
		r.gear_next.should == :over_drive
		r.gear_next.should == :reverse
		r.gear_next.should == :neutral
		r.gear.should == :neutral
		r.gear_previous.should == :reverse
		r.gear_previous.should == :over_drive
		r.gear_previous.should == :second
		r.gear_previous
		r.gear.should == :first
	end
	
	it "should have dynamic predicate methods for :gear attribute" do
		r=RaceCar.new
		r.gear = :second
		r.gear_is_in_second?.should be_true
		r.gear_not_in_second?.should be_false
		r.gear_is_nil?.should be_false
		r.gear_is_not_nil?.should be_true
	end
	
	it "should have working dynamic predicate methods on retrieved objects" do
		r=RaceCar.new
		r.gear = :second
		r.save!
		
		s=RaceCar.find r.id
		s.should_not be_nil
		s.gear_is_in_second?.should be_true
		s.gear_is_not_in_second?.should be_false
		s.gear_is_nil?.should be_false
		s.gear_is_not_nil?.should be_true
	end

  it "should be created and found with dynamic find or creator method" do
    s = RaceCar.find_or_create_by_name_and_gear('specialty', :second)
    s.should_not be_nil
    s.gear.should == :second
    s.name.should == 'specialty'

    s0 = RaceCar.find_or_create_by_name_and_gear('specialty', :second)
    s0.gear.should == :second
    s0.id.should == s.id
  end
  it "should be initialized with dynamic find or initialize method" do
    s = RaceCar.find_or_initialize_by_name_and_gear('myspecialty', :second)
    s.should_not be_nil
    s.gear.should == :second
    s.name.should == 'myspecialty'
    lambda { s.save! }.should_not raise_exception

    s0 = RaceCar.find_or_initialize_by_name_and_gear('myspecialty', :second)
    s0.gear.should == :second
    s0.id.should == s.id
  end
	it "should find record using dynamic finder by enumerated column :gear attributes" do
		r=RaceCar.new
		r.gear = :second
		r.name = 'special'
		r.save!
		
		s=RaceCar.find_by_gear_and_name(:second, 'special')
		s.should_not be_nil
		s.id.should == r.id
	end
	
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
	
	it "should initialize using parameter hash with symbol keys" do
		r=RaceCar.new(:name=>'FastFurious', :gear=>:second, :lights=>'on', :choke=>:medium)
		r.gear.should == :second
		r.lights.should == 'on'
		r.choke.should == :medium
	end
	
	it "should initialize using parameter hash with string keys" do
		r=RaceCar.new({'name'=>'FastFurious', 'gear'=>'second', 'lights'=>'on', 'choke'=>'medium'})
		r.gear.should == :second
		r.lights.should == 'on'
		r.choke.should == :medium
	end
	
	
	it "should convert non-column enumerated attributes from string to symbols" do
		r=RaceCar.new
		r.choke = 'medium'
		r.choke.should == :medium
		r.save!		
	end
	
	it "should convert enumerated column attributes from string to symbols" do
		r=RaceCar.new
		r.gear = 'second'
		r.gear.should == :second
		r.save!

		s=RaceCar.find r.id
		s.gear.should == :second
	end
	
	it "should not convert non-enumerated column attributes from string to symbols" do
		r=RaceCar.new
		r.lights = 'off'
		r.lights.should == 'off'
		r.save!
		
		s=RaceCar.find r.id
		s.lights.should == 'off'
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

	it "should raise InvalidEnumeration for invalid enum passed to attributes=" do
		r=RaceCar.new
		lambda { r.attributes = {:lights=>'off', :gear =>:drive} }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
	end

=begin
	#do not write symbols to enumerated column attributes using write_attribute
	#do not user read_attribute to read an enumerated column attribute
	it "should write enumeration with write_attribute" do
		r=RaceCar.new
		r.write_attribute(:gear, :first)
		r.gear.should == :first
		r.save!
		
		s=RaceCar.find r.id
		s.gear.should == :first
		s.write_attribute(:gear, :second)
		s.save!
		
		t=RaceCar.find s.id
		t.gear.should == :second
	end
	
	it "should raise error when setting enumerated column attribute to invalid enum using write_attribute" do
		r=RaceCar.new
		lambda { r.write_attribute(:gear, :yo) }.should raise_error
	end	
=end
	
	it "should retrieve symbols for enumerations from ActiveRecord :attributes method" do
		r=RaceCar.new
		r.gear = :second
		r.choke = :medium
		r.lights = 'on'
		r.save!
		
		s = RaceCar.find(r.id)
		s.attributes['gear'].should == :second
		s.attributes['lights'].should == 'on'
	end
	
	it "should update_attribute for enumerated column attribute" do
		r=RaceCar.new
		r.gear = :first
		r.save!
		r.update_attribute(:gear, :second)
		r.gear.should == :second
		
		s=RaceCar.find r.id
		s.gear.should == :second
	end
	
	it "should update_attribute for non-enumerated column attribute" do
		r=RaceCar.new
		r.lights = 'on'
		r.save!
		r.update_attribute(:lights, 'off')
		r.lights.should == 'off'
		
		s=RaceCar.find r.id
		s.lights.should == 'off'
	end
	
	it "should update_attributes for both non- and enumerated column attributes" do
		r=RaceCar.new
		r.gear = :first
		r.lights = 'off'
		r.save!
		r.update_attributes({:gear=>:second, :lights=>'on'})
		s=RaceCar.find r.id
		s.gear.should == :second
		s.lights.should == 'on'
		s.update_attributes({:gear=>'over_drive', :lights=>'off'})
		t=RaceCar.find s.id
		t.gear.should == :over_drive
		t.lights.should == 'off'
	end
	
	it "should provide symbol values for enumerated column attributes from the :attributes method" do
		r=RaceCar.new
		r.lights = 'on'
		r.save!
		
		s=RaceCar.find r.id
		s.attributes['gear'].should == :neutral
	end
	
	it "should provide normal values for non-enumerated column attributes from the :attributes method"  do
		r=RaceCar.new
		r.lights = 'on'
		r.save!
		
		s=RaceCar.find r.id
		s.attributes['lights'].should == 'on'
	end
	
	it "should raise InvalidEnumeration when setting invalid enumertion value with :attributes= method" do
		r=RaceCar.new
		lambda { r.attributes = {:gear=>:yo, :lights=>'on'} }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
	end
	
	it "should not set init value for enumerated column attribute saved as nil" do
		r=RaceCar.new
		r.gear = nil
		r.lights = 'on'
		r.save!
		
		s=RaceCar.find r.id
		s.gear.should == nil
		s.lights.should == 'on'
	end
	
	it "should not set init value for enumerated column attributes saved as value" do
		r=RaceCar.new
		r.gear = :second
		r.lights = 'all'
		r.save!
		
		s=RaceCar.find r.id
		s.gear.should == :second
		s.lights.should == 'all'
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
	
	it "should not save values for non-column enumerated attributes" do
		r=RaceCar.new
		r.choke = :medium
		r.save!
		
		s=RaceCar.find r.id
		s.choke.should == :none
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
