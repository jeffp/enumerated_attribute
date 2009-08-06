require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FormTestController do

  #Delete these examples and add some real ones
  it "should use FormTestController" do
    controller.should be_an_instance_of(FormTestController)
  end

  describe "GET 'form'" do
    it "should return gender with male and female choices" do
      get 'form'
      response.should be_success
    end
  end
  
  describe "POST 'form'" do
    
  end

  describe "GET 'form_for'" do
    it "should be successful" do
      get 'form_for'
      response.should be_success
    end
  end
  
  describe "POST 'form_for'" do
  end
  
  describe "GET 'form_tag'" do
    it "should be successful" do
      get 'form_tag'
      response.should be_success
    end
  end
  
  describe "POST 'form_tag'" do
    
  end
end
