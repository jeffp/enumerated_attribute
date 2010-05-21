module EnumeratedAttribute
	module Integrations

		module Default
			def self.included(klass); klass.extend(ClassMethods); end
		
			module ClassMethods
				def define_enumerated_attribute_writer_method(name)
					method_name = "#{name}=".to_sym
					class_eval do
						define_method(method_name) {|val| write_enumerated_attribute(name.to_sym, val) }
          end
				end
				
				def define_enumerated_attribute_reader_method(name)
					name = name.to_sym
					class_eval do
						define_method(name) { read_enumerated_attribute(name) }
          end
				end
			end
		end

	end
end