require 'test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'active_record/inheritance_classes'

def one_to_four; [:one, :two, :three, :four]; end
def gear1; [:reverse, :neutral, :first, :second, :over_drive]; end
def gear2; [:reverse, :neutral, :first, :second, :third, :over_drive]; end
def choke; [:none, :medium, :full]; end

describe "SubRaceCar" do
	it "should have :gear init to :neutral" do
		o=SubRaceCar.new
		o.gear.should == :neutral
		o.enums(:gear).should == gear1
		o.gear_previous.should == :reverse
	end
	it "should have :choke init to :none" do
		o=SubRaceCar.new
		o.choke.should == :none
		o.enums(:choke).should == choke
		o.choke_previous.should == :full
	end
	it "should have :extra init to :one" do
		o=SubRaceCar.new
		o.extra.should == :one
		o.enums(:extra).should == one_to_four
		o.extra_previous.should == :four
	end
end

describe "SubRaceCar2" do
	it "should have :gear init to :neutral" do
		o=SubRaceCar2.new
		o.gear.should == :neutral
		o.enums(:gear).should == gear1
		o.gear_previous.should == :reverse
	end
	it "should have :choke init to :none" do
		o=SubRaceCar2.new
		o.choke.should == :none
		o.enums(:choke).should == choke
		o.choke_previous.should == :full
	end
end

describe "SubRaceCar3" do
	it "should have overridden :gear init to :first" do
		o=SubRaceCar3.new
		o.gear.should == :first
		o.enums(:gear).should == gear2
		o.gear_previous.should == :neutral
	end
	it "should have :choke init to :none" do
		o=SubRaceCar3.new
		o.choke.should == :none
		o.enums(:choke).should == choke
		o.choke_previous.should == :full
	end
end
