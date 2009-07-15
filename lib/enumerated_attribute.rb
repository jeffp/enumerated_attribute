require 'enumerated_attribute/attribute'

module EnumeratedAttribute

	module MacroMethods
		
		def enumerated_attribute(*args, &block)
			class << self
				include EnumeratedAttribute::Attribute
			end
			create_enumerated_attribute(*args, &block)
		end
		alias_method :enum_attr, :enumerated_attribute
		
		#these implementations are for basic ruby objects - integrations (see Integrations::ActiveRecord and Integrations::Object) may alter them
		#def define_enumerated_attribute_custom_method(symbol, attr_name, value, negated)
		#private
		#def define_enumerated_attribute_new_method
		#def define_enumerated_attribute_writer_method name
		#def define_enumerated_attribute_reader_method name
	end
	
end

Class.class_eval do
  include EnumeratedAttribute::MacroMethods
end


