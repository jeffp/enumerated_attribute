
module EnumeratedAttribute
	module Attribute
		class AttributeDescriptor < Array		
			attr_reader :name
			
			def initialize(name, enums=[], opts={})
				super enums
				@name = name
				@options = opts
				@labels_hash = Hash[*self.collect{|e| [e, e.to_s.gsub(/_/, ' ').squeeze(' ').capitalize]}.flatten]
			end
			
			def allows_nil?
				@options[:nil] || true
			end
			def allows_value?(value)
				self.include?(value.to_sym)
			end
				
			def enums
				self
			end
			def label(value)
				@labels_hash[value]
			end
			def labels
				@labels_array ||= self.map{|e| @labels_hash[e]}
			end
			def hash
				@labels_hash
			end
			def select_options
				@select_options ||= self.map{|e| [@labels_hash[e], e.to_s]}
			end
			
			def set_label(enum_value, label_string)
				reset_labels
				@labels_hash[enum_value.to_sym] = label_string
			end
			
			private
			def reset_labels
				@labels_array = nil
				@select_options = nil
			end
			
		end
	end
end
