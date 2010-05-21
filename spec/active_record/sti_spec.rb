require 'test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'active_record/sti_classes'


#contributed by Rob Chekaluk

describe "EnumAttr for STI subclass" do
	it "should assign, save and retrieve non-enumerated attribute" do
		s = StiSub.new()
		s.sub_nonenum = "value2"
    s.save
    s0 = StiSub.find(s.id)
    s0.sub_nonenum.should == "value2"
	end
	it "should assign, save and retrieve subclass enum" do
		s = StiSub.new()
		s.sub_enum = :s3
		s.sub_enum.should == :s3
    s.save
    s0 = StiSub.find(s.id)
    s0.sub_enum.should == :s3
	end
	it "should assign, save and retrieve inherited enum" do
		s = StiSub.new()
    s.parent_enum = :p2
    s.parent_enum.should == :p2
    s.save
    s0 = StiSub.find(s.id)
    s0.parent_enum.should == :p2
	end
end

