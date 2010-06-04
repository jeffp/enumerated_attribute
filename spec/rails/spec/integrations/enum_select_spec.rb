require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper.rb'))

shared_examples_for "enum_select form" do
	it "should have select boxes for gender, status and degree initially set blank" do
		visit form_page
		select_option('', /gender/)
		select_option('', /status/)
		select_option('None', /degree/)
	end
	it "should verify all options for each enumeration" do
		visit form_page
		%w(Male Female).each {|e| select e, :from=>/gender/}
		%w(Single Married Widowed Divorced).each {|e| select e, :from=>/status/}
		["None", "High school", "College", "Graduate"].each {|e| select e, :from=>/degree/}
	end
	it "should submit and keep values when form is invalid" do
		visit form_page
		select 'Male', :from=>/gender/
		select 'Single', :from=>/status/
		select 'College', :from=>/degree/
		click_button 'Save'
		select_option('Male', /gender/)
		select_option('Single', /status/)
		select_option('College', /degree/)
	end
	it "should select values and submit without validation errors and create an object with those values" do
		User.delete_all
		visit form_page
		select 'Male', :from=>/gender/
		select 'Single', :from=>/status/
		select 'College', :from=>/degree/
		fill_in(/first_name/, :with=>'john')
		fill_in(/age/, :with=>'30')
		click_button 'Save'
		#response.code.should be_success
		u = User.find(:first)
		u.first_name.should == 'john'
		u.age.should == 30
		u.gender.should == :male
		u.status.should == :single
		u.degree.should == :college
	end
end

describe "Form using form_for and FormBuilder" do
	def form_page; '/form_test/form_for'; end

	it_should_behave_like "enum_select form"	
	
end

describe "Form using option_helper_tags" do
	def form_page; '/form_test/form_tag'; end
	
	it_should_behave_like "enum_select form"

end

=begin
describe "Form using ActiveRecord helpers" do
	def form_page; '/form_test/form'; end
	puts
	puts "*****************************************************"
	puts "warning: there's a bug in ActionView::Helpers::ActiveRecord 'form' method"
	puts "must change in active_record_helper.rb 'form' method"
	puts "contents = form_tag(:action=>action, :method =>(options[:method] || 'post'), :enctype => options[:multipart] ? 'multipart/form-data': nil)"
	puts "to"
	puts "contents = form_tag(action, :method =>(options[:method] || 'post'), :enctype => options[:multipart] ? 'multipart/form-data': nil)"
	puts "*****************************************************"
	puts
	
	it_should_behave_like "enum_select form"
	
end
=end