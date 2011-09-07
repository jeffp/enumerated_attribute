require 'active_record/test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'active_record/sti_classes'


#contributed by Rob Chekaluk

describe "enum_attr for STI subclass" do
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
  it "should use predicate methods to access enumerated attributes" do
    s=StiSub.create(:parent_enum=>:p2, :sub_enum=>:s1)
    s.parent_enum_is_p2?.should be_true
    s.parent_enum_is_not_p2?.should be_false
    s.sub_enum_is_s2?.should be_false
    s.sub_enum_is_not_s2?.should be_true
  end
end

