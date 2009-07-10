require 'spec/tractor'

describe "Tractor" do

  it "should have respond_to? method for :gear_is_in_neutral?" do
    t=Tractor.new
    t.respond_to?('gear_is_in_neutral?').should be_true
  end
  
  it "should have respond_to? method for :side_light_is_super_high?" do
    t=Tractor.new
    t.respond_to?(:side_light_is_super_high?).should be_true
  end
  
  it "should not have respond_to? method for :gear_is_in_high?" do
    t=Tractor.new
    t.respond_to?(:gear_is_in_high?).should be_false
  end
  
  it "should initially set :plow to :up" do
    t=Tractor.new
    t.plow.should == :up
  end
  
  it "should have plowing? state method" do
    t=Tractor.new
    t.plowing?.should be_false
    t.plow=:down
    t.plowing?.should be_false
    t.gear= :first
    t.plowing?.should be_true
    t.plow=:up
    t.plowing?.should be_false
  end
  
  it "should have :side_light_up incrementor" do
    t=Tractor.new
    t.side_light = :off
    t.side_light_up.should == :low
    t.side_light_up.should == :high
    t.side_light_up.should == :super_high
    t.side_light_up.should == :off
  end
  
  it "should have :side_light_down incrementor" do
    t=Tractor.new
    t.side_light_down.should == :super_high
    t.side_light_down.should == :high
    t.side_light_down.should == :low
    t.side_light_down.should == :off    
  end
  
  it "should have :turn_lights_up incrementor" do
    t=Tractor.new
    t.lights = :off
    t.turn_lights_up.should == :low
    t.turn_lights_up.should == :high
  end
  
  it "should have :turn_lights_down decrementor" do
    t=Tractor.new
    t.lights=:high
    t.turn_lights_down.should == :low
    t.turn_lights_down.should == :off
  end
  
  it "should have :gear_previous which wraps from :neutral to :over_drive" do
    t=Tractor.new
    t.gear_previous.should == :reverse
    t.gear.should == :reverse
    t.gear_previous.should == :over_drive
    t.gear.should == :over_drive
  end
  
  it "should have :gear_next which wraps from :second to :reverse" do
    t=Tractor.new
    t.gear = :second
    t.gear_next.should == :over_drive
    t.gear.should == :over_drive
    t.gear_next.should == :reverse
    t.gear.should == :reverse
  end
  
  it "should have :upshift which increments :gear from :neutral to :over_drive without wrapping" do
    t=Tractor.new
    t.upshift.should == :first
    t.upshift.should == :second
    t.upshift.should == :over_drive
    t.upshift.should == :over_drive
  end
  
  it "should have :downshift which decrements :gear from :over_drive to :neutral without wrapping" do
    t=Tractor.new
    t.gear = :over_drive
    t.downshift.should == :second
    t.downshift.should == :first
    t.downshift.should == :neutral
    t.downshift.should == :neutral
  end

  it "should have parked? method" do
    t=Tractor.new
    t.parked?.should be_true
    t.gear = :reverse
    t.parked?.should be_false
  end
  
  it "should have driving? method"  do
    t=Tractor.new
    t.driving?.should be_false
    [:first, :second, :over_drive].each do |g|
      t.gear=g
      t.driving?.should be_true
    end
  end
  
  it "should initially set side_light to :off" do
    t=Tractor.new
    t.side_light.should == :off
  end
  
  it "should have side_light_enums method" do
    t = Tractor.new
    t.side_light_enums.should == Tractor::SIDE_LIGHT_ENUM_VALUES
  end
  
  it "should have state method side_light_is_off?" do
    t=Tractor.new
    t.side_light_is_off?.should be_true
  end
  
  it "should have state method side_light_is_super_high?" do
    t=Tractor.new
    t.side_light_is_super_high?.should be_false
  end
  
  it "should initially set :gear to :neutral" do
    t=Tractor.new
    t.gear.should == :neutral
  end
    
  it "should set lights initially to :off" do
    t=Tractor.new
    t.lights.should == :off
  end
  
  it "should create a lights_enums method for all light enumerated values" do 
    t=Tractor.new
    t.lights_enums.should == Tractor::LIGHTS_ENUM_VALUES
  end
  
  it "should initially set lights to :off" do
    t=Tractor.new
    t.lights.should equal(:off)
  end

  it "should have dynamic state methods for :reverse and :neutral" do
    t = Tractor.new
    t.gear_is_in_reverse?.should be_false
    t.gear_is_in_neutral?.should be_true
  end
  
  it "should have negative dynamic state methods for :reverses and :neutral" do
    t = Tractor.new
    t.gear_is_not_in_reverse?.should be_true
    t.gear_is_not_in_neutral?.should be_false
  end

  it "should have negative and positive dynamic state methods for :over_drive" do
    t = Tractor.new
    t.gear_is_in_over_drive?.should be_false
    t.gear_is_not_in_over_drive?.should be_true
  end
  
  it "should have created instance methods for :reverse" do
    m = Tractor.instance_methods(false)
    m.should include('gear_is_in_reverse?')
    m.should include('gear_is_not_in_reverse?')
  end

  it "should have created instance methods for :neutral" do
    m = Tractor.instance_methods(false)
    m.should include('gear_is_in_neutral?')
    m.should include('gear_is_not_in_neutral?')
  end

  it "should have created instance methods for :over_drive" do
    m = Tractor.instance_methods(false)
    m.should include('gear_is_in_over_drive?')
    m.should include('gear_is_not_in_over_drive?')
  end
  
  it "should raise NoMethodError for dynamic state methods not querying valid enumeration values" do
    t = Tractor.new
    lambda { t.gear_is_in_high? }.should raise_error(NoMethodError)
  end  
  
  it "should convert string values to symbols for attr setters" do
    t = Tractor.new
    t.gear= 'reverse'
    t.gear.should == :reverse
  end
    
  it "should have class variable @@enumerated_attribute_names" do
    Tractor.class_variable_defined?('@@enumerated_attribute_names').should be_true
  end
  
  it "should have instance method gears equal to enumeration array" do
    Tractor.new.gears.should == Tractor::GEAR_ENUM_VALUES
  end
    
  it "should have gear attribute initialized to :neutral" do
    t = Tractor.new
    t.gear.should == :neutral
  end
  
  it "should set gear attribute to :first" do
    t = Tractor.new
    t.gear = :first
    t.gear.should == :first
  end
  
  it "should raise error when set gear attribute to :broken" do
    t = Tractor.new
    lambda { t.gear= :broken }.should raise_error(ArgumentError)
  end

  it "should have name attribute initially set to 'old faithful'" do
    t = Tractor.new
    t.name.should == 'old faithful'
  end
  
  it "should set name attribute to 'broke n busted'" do
    t = Tractor.new
    t.name = 'broke n busted'
    t.name.should == 'broke n busted'
  end
  
end
