module EnumeratedAttribute
	module Integrations
	
		module Object
			def self.included(klass)
				klass.extend(ClassMethods)
			end

			def write_enumerated_attribute(name, val)
				name = name.to_s
				val = nil if val == ''
				val = val.to_sym if val
				unless self.class.enumerated_attribute_allows_value?(name, val)
					raise(InvalidEnumeration, "nil is not allowed on '#{name}' attribute, set :nil=>true option", caller) unless val
					raise(InvalidEnumeration, ":#{val} is not a defined enumeration value for the '#{name}' attribute", caller) 
				end
				instance_variable_set('@'+name, val)
			end
			
			def read_enumerated_attribute(name)
				instance_variable_get('@'+name.to_s)
			end

			module ClassMethods
				private
				
				def define_enumerated_attribute_new_method
					class_eval <<-NEWMETH
						class << self
							unless method_defined?(:new_without_enumerated_attribute)
								alias_method :new_without_enumerated_attribute, :new
								def new(*args, &block)
									result = new_without_enumerated_attribute(*args)
									result.initialize_enumerated_attributes
									yield result if block_given?
									result
								end
							end
						end
					NEWMETH
				end
				
			end
		
		end	
	end
end