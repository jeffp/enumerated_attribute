module EnumeratedAttribute
	module Integrations

		module ActiveRecord
			def self.included(klass)
				klass.extend(ClassMethods)
				klass.validate :validate_enumerated_attribute
			end

			def validate_enumerated_attribute
				attributes.each do |k,v|
					if self.class.has_enumerated_attribute?(k) and not self.class.enumerated_attribute_allows_value?(k, v)
						if v
							errors.add(k, :inclusion)
						else
							errors.add(k, :blank)
						end
					end
				end
			end

			def write_enumerated_attribute(name, val)
				name = name.to_s
				return write_attribute(name, val) unless self.class.has_enumerated_attribute?(name)
				val = nil if val == ''
				val_str = val.to_s if val
				val_sym = val.to_sym if val
				return instance_variable_set('@'+name, val_sym) unless self.has_attribute?(name)
				write_attribute(name, val_str)
				val_sym
			end

			def read_enumerated_attribute(name)
				name = name.to_s
				#if not enumerated - let active record handle it
				return read_attribute(name) unless self.class.has_enumerated_attribute?(name)
				#if enumerated, is it an active record attribute, if not, the value is stored in an instance variable
				name_sym = name.to_sym
				return instance_variable_get('@'+name) unless self.has_attribute?(name)
				#this is an enumerated active record attribute
				val = read_attribute(name)
				val = val.to_sym if !!val
				val
			end

			def attributes=(attrs)
				return if attrs.nil?
				#check the attributes then turn them over
				attrs.each do |k, v|
					attrs[k] = v.to_s if self.class.has_enumerated_attribute?(k)
				end

				super
			end

			def attributes
				atts = super
				atts.each do |k,v|
					if self.class.has_enumerated_attribute?(k)
						atts[k] = v.to_sym if v
					end
				end
				atts
			end

      def [](attr_name); read_enumerated_attribute(attr_name); end
      def []=(attr_name, value); write_enumerated_attribute(attr_name, value); end

			private

			def attribute=(attr_name, value); write_enumerated_attribute(attr_name, value); end

			module ClassMethods
				def instantiate(record)
					object = super(record)
					self.enumerated_attributes.each do |k,v|
						unless object.has_attribute?(k) #only initialize the non-column enumerated attributes
							object.write_enumerated_attribute(k, v.init_value)
						end
					end
					object
				end

				private

				def construct_attributes_from_arguments(attribute_names, arguments)
          attributes = {}
          attribute_names.each_with_index{|name, idx| attributes[name] = has_enumerated_attribute?(name) ? arguments[idx].to_s : arguments[idx]}
          attributes
				end

				def define_enumerated_attribute_new_method
					class_eval do
						class << self
							unless method_defined?(:new_without_enumerated_attribute)
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
              unless private_method_defined?(:method_missing_without_enumerated_attribute)
                define_chained_method(:method_missing, :enumerated_attribute) do |method_id, *arguments|
                  arguments = arguments.map{|arg| arg.is_a?(Symbol) ? arg.to_s : arg }
                  method_missing_without_enumerated_attribute(method_id, *arguments)
                end
              end
						end
          end
				end
			end
		end
	end
end
