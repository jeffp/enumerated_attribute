class FormTestController < ApplicationController
  
  def index  
  end
  
  #ActionView::Helpers:ActiveRecordHelper
  def form
    @user = User.new(params[:user])
    return if request.get?
    
    return unless @user.save
    redirect_to :action=>:index
  end

  #ActionView::Helpers::FormHelper
  def form_for
    @user = User.new(params[:user])
    return if request.get?
    
    return unless @user.save
    redirect_to :action=>:index
  end

  #ActionView::Helpers::FormTagHelper
  def form_tag
    @user = User.new(params[:user])
    return if request.get?
    
    return unless @user.save
    redirect_to :action=>:index
  end
  
  #ActionView::Helpers::FormOptionsHelper
#  def select
#    
#  end

end
