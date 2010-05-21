require 'test_in_memory'
require 'enumerated_attribute'
require 'active_record'
require 'active_record/sti_classes'

class StiParent < ActiveRecord::Base
  enum_attr :parent_enum, %w(p1 p2 p3)

end

class StiSub < StiParent
  enum_attr :sub_enum, %w(s1 s2 s3)
end

