module EnumeratedAttribute
	module Integrations

		module ActiveRecord
			def self.included(klass)
				klass.extend(ClassMethods)
			end
			
			def write_enumerated_attribute(name, val)
				name = name.to_s
				return write_attribute(name, val) unless self.class.has_enumerated_attribute?(name)
				val_str = val.to_s if val
				val_sym = val.to_sym if val
				unless self.class.enumerated_attribute_allows_value?(name, val_sym)
					raise(InvalidEnumeration, "nil is not allowed on '#{name}' attribute, set :nil=>true option", caller) unless val
					raise(InvalidEnumeration, ":#{val_str} is not a defined enumeration value for the '#{name}' attribute", caller)
				end
				return instance_variable_set('@'+name, val_sym) unless self.has_attribute?(name)
				write_attribute(name, val_str)
			end
			
			def read_enumerated_attribute(name)
				name = name.to_s
				#if not enumerated - let active record handle it
				return read_attribute(name) unless self.class.has_enumerated_attribute?(name)
				#if enumerated, is it an active record attribute, if not, the value is stored in an instance variable
				return instance_variable_get('@'+name) unless self.has_attribute?(name)
				#this is an enumerated active record attribute
				val = read_attribute(name)
				val = val.to_sym if (!!val && self.class.has_enumerated_attribute?(name))
				val
			end
			
			def attributes=(attrs, guard_protected_attributes=true)
				return if attrs.nil?
				#check the attributes then turn them over 
				attrs.each do |k, v|
					if self.class.has_enumerated_attribute?(k)
						unless self.class.enumerated_attribute_allows_value?(k, v)
							raise InvalidEnumeration, ":#{v.to_s} is not a defined enumeration value for the '#{k.to_s}' attribute", caller
						end
						attrs[k] = v.to_s
					end
				end
				
				super
			end
			
			def attributes
				super.map do |k,v|
					self.class.has_enumerated_attribute?(k) ? v.to_sym : v
				end
			end
			
      def [](attr_name); read_enumerated_attribute(attr_name); end
      def []=(attr_name, value); write_enumerated_attribute(attr_name, value); end
			
			private
						
			def attribute=(attr_name, value); write_enumerated_attribute(attr_name, value); end
									
			module ClassMethods
				private
				
				def construct_attributes_from_arguments(attribute_names, arguments)
					attributes = super
					attributes.each { |k,v| attributes[k] = v.to_s if has_enumerated_attribute?(k) }
					attributes
				end			
				
				def instantiate(record)
					object = super(record)
					@enumerated_attribute_init.each do |k,v|
						unless object.has_attribute?(k)
							object.write_enumerated_attribute(k, v)
						end
					end
					object
				end
				
				def define_enumerated_attribute_new_method
					class_eval <<-INITVAL
						class << self
							alias_method :new_without_enumerated_attribute, :new
							def new(*args, &block)
								result = new_without_enumerated_attribute(*args, &block)
								params = (!args.empty? && args.first.instance_of?(Hash)) ? args.first : {}
								params.each { |k, v| result.write_enumerated_attribute(k, v) }
								result.initialize_enumerated_attributes(true)
								yield result if block_given?
								result
							end
						end
					INITVAL
				end

			end
		end	
	end
end