require 'tractor'
require 'plural'

describe "Plural" do
	it "should have plural accessor :boxes for :box" do
		p=Plural.new
		p.methods.should include("boxes")
		p.boxes.should == [:small, :medium, :large]
	end
	it "should have plural accessor :batches for :batch" do
		p=Plural.new
		p.methods.should include("batches")
		p.batches.should == [:none, :daily, :weekly]
	end
	it "should have plural accessor :cherries for :cherry" do
		p=Plural.new
		p.methods.should include("cherries")
		p.cherries.should == [:red, :green, :yellow]
	end
	it "should have plural accessor :guys for :guy" do
		p=Plural.new
		p.methods.should include("guys")
		p.guys.should == [:handsome, :funny, :cool]
	end
	
end

describe "Tractor" do

	it "should have default labels for :gear attribute" do
		labels_hash = {:reverse=>'Reverse', :neutral=>'Neutral', :first=>'First', :second=>'Second', :over_drive=>'Over drive'}
		labels = ['Reverse', 'Neutral', 'First', 'Second', 'Over drive']
		select_options = [['Reverse', 'reverse'], ['Neutral', 'neutral'], ['First', 'first'], ['Second', 'second'], ['Over drive', 'over_drive']]
		t=Tractor.new
		t.gears.labels.should == labels
		labels_hash.each do |k,v|
			t.gears.label(k).should == v
		end
		t.gears.hash.should == labels_hash
		t.gears.select_options.should == select_options
	end
	
	it "should retrieve :gear enums through enums method" do
		t=Tractor.new
		t.enums(:gear).should == t.gears
	end
	
	it "should retrieve custom labels for :side_light attribute" do
		labels_hash = {:off=>'OFF', :low=>'LOW DIM', :high=>'HIGH BEAM', :super_high=>'SUPER BEAM'}
		t=Tractor.new
		enum = t.enums(:side_light)
		t.enums(:side_light).hash.each do |k,v|
			enum.label(k).should == labels_hash[k]
		end
	end
	
	it "should return a Symbol type from reader methods" do
		t=Tractor.new
		t.gear.should be_an_instance_of(Symbol)
	end	
	
	it "should not raise errors for dynamic predicate methods missing attribute name" do
		t=Tractor.new
		lambda{ t.neutral?.should be_true }.should_not raise_error
		lambda{ t.is_neutral?.should be_true }.should_not raise_error
		lambda{ t.not_neutral?.should be_false}.should_not raise_error
		t.gear = :first
		t.neutral?.should be_false
		t.not_neutral?.should be_true
	end
	
	it "should raise AmbiguousMethod when calling :off?" do
		t=Tractor.new
		lambda { t.off? }.should raise_error(EnumeratedAttribute::AmbiguousMethod)
	end
	
	it "should raise AmbiguousMethod when calling :in_reverse?" do
		t=Tractor.new
		lambda {t.in_reverse?}.should raise_error(EnumeratedAttribute::AmbiguousMethod)
	end
	
	it "should raise AmbiguousMethod when calling :not_reverse?" do
		t=Tractor.new
		lambda {t.not_reverse?}.should raise_error(EnumeratedAttribute::AmbiguousMethod)
	end	

  it "should initialize :gear for two instances of the same class" do
		t=Tractor.new
		t.gear.should == :neutral
		s=Tractor.new
		s.gear.should == :neutral
	end
	
  it "should dynamically create :plow_nil? and :plow_not_nil?" do
    t=Tractor.new
    t.plow_nil?.should be_false
    t.plow_not_nil?.should be_true
    t.plow = nil
    t.plow_not_nil?.should be_false
    t.plow_nil?.should be_true
    Tractor.instance_methods(false).should include('plow_nil?')
    Tractor.instance_methods(false).should include('plow_not_nil?')
  end
  
  it "should dynamically create :plow_is_nil? and :plow_is_not_nil?" do
    t=Tractor.new
    t.plow_is_nil?.should be_false
    t.plow_is_not_nil?.should be_true
    t.plow = nil
    t.plow_is_not_nil?.should be_false
    t.plow_is_nil?.should be_true
    Tractor.instance_methods(false).should include('plow_is_nil?')
    Tractor.instance_methods(false).should include('plow_is_not_nil?')    
  end
  
  it "should negate result for not_parked? defined with is_not" do
    t=Tractor.new
    t.gear = :neutral
    t.not_parked?.should be_false
  end
  
  it "should negate result for not_driving? defined with is_not" do
    t=Tractor.new
    t.gear = :neutral
    t.not_driving?.should be_true
  end

=begin
  it "should have getter but no setter for :temperature" do
    Tractor.instance_methods.should_not include('temperature=')
    Tractor.instance_methods.should include('temperature')
  end
  
  it "should have setter but no getter for :ignition" do
    Tractor.instance_methods.should_not include('ignition')
    Tractor.instance_methods.should include('ignition=')
  end
=end

  it "should be able to set :plow to nil" do
    t=Tractor.new
    lambda { t.plow = nil }.should_not raise_error(EnumeratedAttribute::InvalidEnumeration)
  end
  
  it "should have method :plow_nil? that operates correctly" do
    t=Tractor.new
    t.plow.should_not be_nil
    t.plow_nil?.should be_false
    t.plow = nil
    t.plow.should be_nil
    t.plow_nil?.should be_true
  end
  
  it "should raise EnumeratedAttribute::InvalidEnumeration when setting :gear to nil" do
    t=Tractor.new
    lambda{ t.gear = nil }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
  end
  
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
    lambda { t.gear= :broken }.should raise_error(EnumeratedAttribute::InvalidEnumeration)
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
