module EnumeratedAttribute
	module Integrations

		module Default
			def self.included(klass); klass.extend(ClassMethods); end
		
			module ClassMethods
				def define_enumerated_attribute_writer_method name
					name = name.to_s
					class_eval <<-METHOD
						def #{name}=(val); write_enumerated_attribute(:#{name}, val); end    
					METHOD
				end
				
				def define_enumerated_attribute_reader_method name
					name = name.to_s
					class_eval <<-METHOD
						def #{name}; read_enumerated_attribute(:#{name}); end
					METHOD
				end
			end
		end

	end
end