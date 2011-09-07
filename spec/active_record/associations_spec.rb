require 'active_record/test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'active_record/association_test_classes'

module TestVariables
	def company_name; 'Company A'; end
end

describe "Polymorphic associations" do
	include TestVariables
	
	it "should retrieve enum'ed attribute for articles and images of a comment" do
		c1 = Comment.new(:comment=>'i like it')
		c1.document = Article.create!(:name=>'Birds of a Feather', :status=>:accepted)
		c1.save!
		c1.status.should == :unflagged
		
		c2 = Comment.new(:comment=>'i hate it', :status => :flagged)
		c2.document = Image.create!(:name=>'Martian Landscape', :status=>:unreviewed)
		c2.save!
		c2.status.should == :flagged
		
		Comment.find(c1.id).document.status.should == :accepted
		Comment.find(c2.id).document.status.should == :unreviewed

	end
	
	it "should retrieve enum'ed attribute for comments on articles and images" do
		a = Article.create!(:name=>'Swimming with Whales', :status=>:accepted)
		a.create_comment(:comment=>'i like it', :status=>:unflagged)
		a.save!
		
		i = Image.create!(:name=>'Mountain Climbing', :status=>:unreviewed)
		i.comment = Comment.create!(:comment=>'i do not like it', :status=>:flagged)
		i.save!
		
		Image.find(i.id).comment.status.should == :flagged
		Article.find(a.id).comment.status.should == :unflagged
		
	end
	
end

describe "Basic Associations" do
	include TestVariables

	it "should retrieve enum'ed status for its license" do
		c = Company.new(:status=>:llc, :name=>company_name)
		c.save!
		c.create_license(:status=>:current)
		
		r = Company.find(c.id)
		lic = r.license
		r.status.should == :llc
		lic.status.should == :current
	end
	
	it "should retrieve enum'ed status for multiple employees" do
		c=Company.new(:status=>:llc, :name=>company_name)
		c.save!
		c.employees.create!(:status=>:full_time, :name=>'edward')
		c.employees.create!(:status=>:suspended, :name=>'tina')
		
		r=Company.find(c.id)
		r.employees.find_by_name('edward').status.should == :full_time		
		r.employees.find_by_name('tina').status.should == :suspended		
		Employee.delete_all
	end
	
	it "should retrieve enum'ed status for multiple contractors" do
		c=Company.new(:status=>:llc, :name=>company_name)
		c.save!
		c1 = Contractor.new(:status=>:available, :name=>'john')
		c2 = Contractor.new(:status=>:unavailable, :name=>'sally')
		c.contractors << c1
		c.contractors << c2
		
		r=Company.find(c.id)
		r.contractors.find_by_name('sally').status.should == :unavailable
		r.contractors.find_by_name('john').status.should == :available
		Contractor.delete_all
		ContractWorker.delete_all
	end
end

describe "License" do
	include TestVariables
  it "should retrieve the status for the company" do
		Company.delete_all
		License.delete_all
		lic = License.create!(:status=>:expired)
		lic.company = Company.create!(:name=>company_name, :status=>:llc)
		lic.save!
		
		License.find(lic.id).company.status.should == :llc
	end
end

describe "Contractor" do
	include TestVariables
	it "should retrieve enum'ed status from multiple companies" do
		Company.delete_all
		Contractor.delete_all
		ContractWorker.delete_all
		c = Contractor.create!(:name=>'jack', :status=>:available)
		
		c1 = Company.create!(:name=>company_name, :status=>:s_corp)
		c2 = Company.create!(:name=>'other company', :status=>:llc)
		c.companies << c1 << c2
		
		j = Contractor.find(c.id)
		j.companies.find_by_name('other company').status.should == :llc
		j.companies.find_by_name(company_name).status.should == :s_corp		
	end
end

describe "Employee" do
	include TestVariables
	it "should retrieve enum'ed status from the company" do
		Company.delete_all
		Employee.delete_all
		e = Employee.create!(:name=>'juanita', :status=>:part_time)
		e.company = Company.create!(:name=>company_name, :status=>:c_corp)
		e.save!
		
		emp = Employee.find(e.id)
		emp.company.status.should == :c_corp
	end
end
