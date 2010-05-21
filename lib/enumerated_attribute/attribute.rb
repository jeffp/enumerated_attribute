require 'enumerated_attribute/attribute/attribute_descriptor'
require 'enumerated_attribute/method_definition_dsl'
require 'enumerated_attribute/integrations'
require 'enumerated_attribute/rails_helpers'
require 'ostruct'

module EnumeratedAttribute

	class EnumeratedAttributeError < StandardError; end
	class IntegrationError < EnumeratedAttributeError; end
	class InvalidEnumeration < EnumeratedAttributeError; end
	class InvalidDefinition < EnumeratedAttributeError; end
	class AmbiguousMethod < EnumeratedAttributeError; end

	module Attribute
			private
      def validate_enum_attr_arguments(config)
				raise(InvalidDefinition, 'second argument of enumerated_attribute/enum_attr is not an array of symbols or strings representing the enum values', caller) if config.enums.empty?
      end
      def init_incrementor_decrementor_method_names(config)
				config.incrementor = config.opts[:incrementor] || config.opts[:inc] || "#{config.attr_name}_next"
				config.decrementor = config.opts[:decrementor] || config.opts[:dec] || "#{config.attr_name}_previous"
      end
      def init_plural_name(config)
				config.plural_name = config.opts[:plural] || config.opts[:enums_accessor] || config.opts[:enums] || begin
				case
					when config.attr_name =~ /[aeiou]y$/
						"#{config.attr_name}s"
					when config.attr_name =~ /y$/
						config.attr_name.sub(/y$/, 'ies')
					when config.attr_name =~ /(sh|ch|x|s)$/
						"#{config.attr_name}es"
					else
						"#{config.attr_name}s"
					end
				end
      end
      def process_enums_for_initial_value(config)
        config.initial_value = nil
				config.enums = config.enums.map{|v| (v =~ /^\^/ ? (config.initial_value ||= v[1, v.length-1].to_sym) : v.to_sym )}
      end

      def parse_enum_attr_arguments(args)
        config = OpenStruct.new
        config.attr_name = args[0].to_s
        config.attr_symbol = config.attr_name.to_sym
        config.enums = (args[1] && args[1].is_a?(Array) ? args[1] : [])
        index = config.enums.empty? ? 1 : 2
        config.opts = (args[index] && args[index].is_a?(Hash) ? args[index] : {})

        validate_enum_attr_arguments(config)
        init_plural_name(config)
        init_incrementor_decrementor_method_names(config)
        process_enums_for_initial_value(config)

        config
      end


			def create_enumerated_attribute(*args, &block)
				return if args.empty?
        config = parse_enum_attr_arguments(args)
				
				class_eval do
					def self.enumerated_attributes(all=true)
						return @enumerated_attributes unless all
						return @all_enumerated_attributes_cache if @all_enumerated_attributes_cache
						@all_enumerated_attributes_cache = @enumerated_attributes ?  @enumerated_attributes.dup : {}
						klass = self.superclass
						while (klass)
							if (klass.respond_to?(:enumerated_attributes))
								if (sub_enums = klass.enumerated_attributes)
									@all_enumerated_attributes_cache = sub_enums.merge @all_enumerated_attributes_cache
									break
								end
							end
							klass = klass.superclass
						end
						@all_enumerated_attributes_cache
					end
					def enums(attr); self.class.enumerated_attributes[attr.to_sym]; end
					@enumerated_attributes ||= {}
					@enumerated_attributes[config.attr_symbol] = AttributeDescriptor.new(config.attr_symbol, config.enums, config.opts)
        end
				
				#define_enumerated_attribute_[writer, reader] may be modified in a named Integrations module (see Integrations::ActiveRecord)
				class_eval do
					unless @integration_map
						@integration_map = Integrations.find_integration_map(self)
						@integration_map[:aliasing].each do |p|
							alias_method(p.first, p.last)
						end
						include(EnumeratedAttribute::Integrations::Default)
						include(@integration_map[:module]) if @integration_map[:module]
						
						def self.has_enumerated_attribute?(name)
							return(false) if name.nil?
							self.enumerated_attributes.key?(name.to_sym)
						end
						def self.enumerated_attribute_allows_nil?(name)
							return(false) unless (descriptor = self.enumerated_attributes[name.to_sym])
							descriptor.allows_nil?
						end
						def self.enumerated_attribute_allows_value?(name, value)
							return (false) unless (descriptor = self.enumerated_attributes[name.to_sym])
							return descriptor.allows_nil? if (value == nil || value == '')
							descriptor.allows_value?(value)
						end
					end
        end
				
				#create accessors
				define_enumerated_attribute_reader_method(config.attr_symbol) unless (config.opts.key?(:reader) && !config.opts[:reader])
				define_enumerated_attribute_writer_method(config.attr_symbol) unless (config.opts.key?(:writer) && !config.opts[:writer])
				
				#define dynamic methods in method_missing
				class_eval do
					unless @enumerated_attribute_define_once_only
            method_missing_suffix = "enumerated_attribute_#{self.class.name}_#{self.hash}".to_sym
            define_method("method_missing_with_#{method_missing_suffix}") do |methId, *args|
              return self.__send__(methId) if define_enumerated_attribute_dynamic_method(methId)
              self.__send__("method_missing_without_#{method_missing_suffix}", methId, *args)
            end
            safe_alias_method_chain :method_missing, method_missing_suffix
						@enumerated_attribute_define_once_only = true

            respond_to_suffix = "enumerated_attribute_#{self.class.name}_#{self.hash}".to_sym
            define_method("respond_to_with_#{respond_to_suffix}?") do |method|
              self.__send__("respond_to_without_#{respond_to_suffix}?".to_sym, method.to_sym) ||
                (!!parse_dynamic_method_parts!(method.to_s) rescue false)
            end
            safe_alias_method_chain :respond_to?, respond_to_suffix
						
						def initialize_enumerated_attributes(only_if_nil = false)
							#self.class.enumerated_attribute_initial_value_list.each do |k,v|
							#	self.write_enumerated_attribute(k, v) unless (only_if_nil && read_enumerated_attribute(k) != nil)
							#end
							self.class.enumerated_attributes.each do |k,v|
								self.write_enumerated_attribute(k, v.init_value) unless (only_if_nil && read_enumerated_attribute(k) != nil)
							end
						end

						private
						
						def parse_dynamic_method_parts!(meth_name)
							return(nil) unless meth_name[-1, 1] == '?'
							
							middle = meth_name.chop #remove the ?
							
							attr = nil
							self.class.enumerated_attributes.keys.each do |name|
								if middle.sub!(Regexp.new("^"+name.to_s), "")
									attr = name; break
								end
							end
							
							value = nil
							attr_sym = attr ? attr.to_sym : nil
							if (descriptor = self.class.enumerated_attributes[attr_sym])
								descriptor.enums.each do |v|
									if middle.sub!(Regexp.new(v.to_s+"$"), "")
										value = v; break
									end
								end	
							else
								#search through enum values one at time and identify any ambiguities
								self.class.enumerated_attributes.each do |attr_key,descriptor|
									descriptor.enums.each do|v|
										if middle.match(v.to_s+"$")
											raise(AmbiguousMethod, meth_name+" is ambiguous, use something like "+attr_sym.to_s+(middle[0,1]=='_'? '' : '_')+middle+"? or "+attr_key.to_s+(middle[0,1]=='_'? '' : '_')+middle+"?", caller) if attr_sym
											attr_sym = attr_key
											value = v
										end
									end
								end
								return (nil) unless attr_sym
								attr = attr_sym.to_s
								middle.sub!(Regexp.new(value.to_s+"$"), "")
							end
						
							unless value #check for nil?
								return (nil) unless middle.sub!(Regexp.new('nil$'), "")
								value = nil
							end
							
							[attr, middle, value]
						end
					
						def define_enumerated_attribute_dynamic_method(methId)
							meth_name = methId.id2name
							parts = parse_dynamic_method_parts!(meth_name)
							return(false) unless parts
							
							negated = !!parts[1].downcase.match(/(^|_)not_/)
							value = parts[2] ? parts[2].to_sym : nil
							self.class.define_enumerated_attribute_custom_method(methId, parts[0], value, negated)
							
							true
						end
										
					end
        end

				#create state and action methods from block
				config.initial_value = config.opts[:init] || config.initial_value
				if block_given?
					m = EnumeratedAttribute::MethodDefinitionDSL.new(self, self.enumerated_attributes(false)[config.attr_symbol]) #attr_name, enums)
					m.instance_eval(&block)
					config.initial_value = m.initial_value || config.initial_value
					config.plural_name = m.pluralized_name || config.plural_name
					config.decrementor = m.decrementor_name || config.decrementor
					config.incrementor = m.incrementor_name || config.incrementor
				end

				#define the enum values accessor
				class_eval do
          define_method(config.plural_name.to_sym) { self.class.enumerated_attributes[config.attr_symbol]}
					define_method(config.incrementor.to_sym) do
						z = self.class.enumerated_attributes[config.attr_symbol].enums
						index = z.index(read_enumerated_attribute(config.attr_symbol))
						write_enumerated_attribute(config.attr_symbol, z[index >= z.size-1 ? 0 : index+1])
					end
  				define_method(config.decrementor.to_sym) do
						z = self.class.enumerated_attributes[config.attr_symbol].enums
						index = z.index(read_enumerated_attribute(config.attr_symbol))
						write_enumerated_attribute(config.attr_symbol, z[index > 0 ? index-1 : z.size-1])
					end
        end
				
				#unless defined?(@enumerated_attribute_init)
					define_enumerated_attribute_new_method
				#end
				#@enumerated_attribute_init ||= {}		
				#if (initial_value = opts[:init] || initial_value)
				#	@enumerated_attribute_init[attr_sym] = initial_value 
				#end
				class_eval do
					@enumerated_attributes ||={}
					if (config.initial_value = config.opts[:init] || config.initial_value)
						@enumerated_attributes[config.attr_symbol].init_value = config.initial_value
					end
					#def self.enumerated_attribute_initial_value_list; @enumerated_attribute_init; end
				end
				
				def self.define_enumerated_attribute_custom_method(symbol, attr_name, value, negated)
					define_method symbol do
						ival = read_enumerated_attribute(attr_name)
						negated ? ival != value : ival == value
					end
				end
				
			end		
		end
		
		#these methods are called by create_enumerated_attribute but defined by the integration (see Integrations::ActiveRecord and Integrations::Object) may alter them
		#def define_enumerated_attribute_custom_method(symbol, attr_name, value, negated)
		#private
		#def define_enumerated_attribute_new_method
		#def define_enumerated_attribute_writer_method name
		#def define_enumerated_attribute_reader_method name		
	
end
