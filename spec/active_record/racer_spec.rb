require 'test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'racer'

describe "Racer" do

	it "should save and retrieve its name" do
		r = Racer.new(:name=>'Green Meanie')
		r.save!
		
		s = Racer.find_by_name('Green Meanie')
		s.should_not be_nil
		s.name.should == 'Green Meanie'
	end
	
	it "should work for enumerated attribute" do
		r = Racer.new
		r.name = 'Green Meanie2'
		r.gear = :first
		r.save!
		
		s = Racer.find_by_name('Green Meanie2')
		s.should_not be_nil
		s.gear.should == :first
	end
	
	
end
