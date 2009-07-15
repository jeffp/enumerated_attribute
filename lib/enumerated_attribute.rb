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
		
	end
	
end

Class.class_eval do
  include EnumeratedAttribute::MacroMethods
end


