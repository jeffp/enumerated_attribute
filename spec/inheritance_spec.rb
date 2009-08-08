require 'inheritance_classes'

def one_to_four; [:one, :two, :three, :four]; end
def five_to_eight; [:five, :six, :seven, :eight]; end

describe "Base" do
	it "should have :base1 init to :one" do
		o=Base.new
		o.base1.should == :one
		o.enums(:base1).should == one_to_four
		o.base1_previous.should == :four
	end
	it "should have :inherited1 init to :one" do
		o=Base.new
		o.inherited1.should == :one
		o.enums(:inherited1).should == one_to_four
		o.inherited1_previous.should == :four
	end
	it "should have :inherited2 init to :one" do
		o=Base.new
		o.inherited2.should == :one
		o.enums(:inherited2).should == one_to_four
		o.inherited2_previous.should == :four
	end	
end

describe "Sub<Base" do
	it "should instantiate an object" do
		lambda { s=Sub.new }.should_not raise_error
	end
	it "should have :sub1 init to :two" do
		o=Sub.new
		o.sub1.should == :two
		o.enums(:sub1).should == one_to_four
		o.sub1_previous.should == :one
	end
	it "should have :base1 init to :one" do
		o=Sub.new
		o.base1.should == :one
		o.enums(:base1).should == one_to_four
		o.base1_previous.should == :four
	end
	it "should have :inherited1 init to :two" do
		o=Sub.new
		o.inherited1.should == :two
		o.enums(:inherited1).should == one_to_four
		o.inherited1_previous.should == :one
	end
	it "should have :inherited2 init to :five" do
		o=Sub.new
		o.inherited2.should == :five
		o.enums(:inherited2).should == five_to_eight
		o.inherited2_previous.should == :eight
	end		
end

describe "Sub2<Base" do
	it "should instantiate an object" do
		lambda {s=Sub2.new}.should_not raise_error
	end
	it "should have :base1 init to :one" do
		o=Sub2.new
		o.base1.should == :one
		o.enums(:base1).should == one_to_four
		o.base1_previous.should == :four
	end
	it "should have :inherited1 init to :one" do
		o=Sub2.new
		o.inherited1.should == :one
		o.enums(:inherited1).should == one_to_four
		o.inherited1_previous.should == :four
	end
	it "should have :inherited2 init to :one" do
		o=Sub2.new
		o.inherited2.should == :one
		o.enums(:inherited2).should == one_to_four
		o.inherited2_previous.should == :four
	end	
end

