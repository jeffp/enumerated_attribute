#irb -r cfg ==> to work configure for working in IRB
$:.unshift '../../lib'
require 'active_record/test_in_memory'
require 'enumerated_attribute'
require 'active_record/race_car'
require 'active_record/sti_classes'
