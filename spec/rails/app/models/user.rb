require 'enumerated_attribute'
class User < ActiveRecord::Base
  validates_presence_of :first_name, :gender, :age, :status, :degree
  validates_numericality_of :age
  
  enum_attr :gender, %w(male female)
  enum_attr :status, %w(single married divorced widowed)
  enum_attr :degree, %w(^none high_school college graduate)
end
