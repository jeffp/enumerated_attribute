#irb -r cfg ==> to work configure for working in IRB
$:.unshift '../../lib'
require 'test_in_memory'
require 'enumerated_attribute'
require 'race_car'
require 'sti_classes'
