require 'enumerated_attribute/method_definition_dsl'
require 'enumerated_attribute/integrations'

module EnumeratedAttribute

	class EnumeratedAttributeError < StandardError; end
	class IntegrationError < EnumeratedAttributeError; end
	class InvalidEnumeration < EnumeratedAttributeError; end
	class InvalidDefinition < EnumeratedAttributeError; end
	class AmbiguousMethod < EnumeratedAttributeError; end

	module Attribute
	
			private
			def create_enumerated_attribute(*args, &block)
				return if args.empty?
				attr_name = args[0].to_s
				attr_sym = attr_name.to_sym
				enums = (args[1] && args[1].instance_of?(Array) ? args[1] : [])
				index = enums.empty? ? 1 : 2
				opts = (args[index] && args[index].instance_of?(Hash) ? args[index] : {})
				
				raise(InvalidDefinition, 'second argument of enumerated_attribute/enum_attr is not an array of symbols or strings representing the enum values', caller) if enums.empty?

				initial_value = nil
				plural_name = opts[:plural] || opts[:enums_accessor] || opts[:enums] || begin 
					case
					when attr_name =~ /[aeiou]y$/
						"#{attr_name}s"
					when attr_name =~ /y$/
						attr_name.sub(/y$/, 'ies')
					when attr_name =~ /(sh|ch|x|s)$/
						"#{attr_name}es"
					else
						"#{attr_name}s"
					end
				end
				incrementor = opts[:incrementor] || opts[:inc] || "#{attr_name}_next"
				decrementor = opts[:decrementor] || opts[:dec] || "#{attr_name}_previous"

				enums = enums.map{|v| (v =~ /^\^/ ? (initial_value = v[1, v.length-1].to_sym) : v.to_sym )}

				class_eval <<-ATTRIB
					@@enumerated_attribute_names ||= []
					@@enumerated_attribute_names << '#{attr_name}'
					@@enumerated_attribute_options ||={}
					@@enumerated_attribute_options[:#{attr_name}] = {#{opts.to_a.map{|v| ':'+v.first.to_s+'=>:'+v.last.to_s}.join(', ')}}
					@@enumerated_attribute_values ||= {}
					@@enumerated_attribute_values[:#{attr_name}] = [:#{enums.join(',:')}]
				ATTRIB
				
				#define_enumerated_attribute_[writer, reader] may be modified in a named Integrations module (see Integrations::ActiveRecord)
				class_eval <<-MAP
					unless @integration_map
						@integration_map = Integrations.find_integration_map(self)
						@integration_map[:aliasing].each do |p|
							alias_method(p.first, p.last)
						end
						include(EnumeratedAttribute::Integrations::Default)
						include(@integration_map[:module]) if @integration_map[:module]
						
						def self.has_enumerated_attribute?(name)
							@@enumerated_attribute_names.include?(name.to_s)
						end
						def self.enumerated_attribute_allows_nil?(name)
							return (false) unless @@enumerated_attribute_options[name.to_sym]
							@@enumerated_attribute_options[name.to_sym][:nil] || false
						end
						def self.enumerated_attribute_allows_value?(name, value)
							return (false) unless @@enumerated_attribute_values[name.to_sym]
							return enumerated_attribute_allows_nil?(name) if value == nil
							@@enumerated_attribute_values[name.to_sym].include?(value.to_sym)
						end
					end
				MAP
				
				#create accessors
				define_enumerated_attribute_reader_method(attr_sym) unless (opts.key?(:reader) && !opts[:reader])
				define_enumerated_attribute_writer_method(attr_sym) unless (opts.key?(:writer) && !opts[:writer])
				
				#define dynamic methods in method_missing
				class_eval <<-METHOD
					unless @enumerated_attribute_define_once_only
						if method_defined?(:method_missing)
							alias_method(:method_missing_without_enumerated_attribute, :method_missing)
							def method_missing(methId, *args, &block)
								return self.send(methId) if define_enumerated_attribute_dynamic_method(methId)
								method_missing_without_enumerated_attribute(methId, *args, &block)
							end
						else
							def method_missing(methId, *args, &block)
								return self.send(methId) if define_enumerated_attribute_dynamic_method(methId)
								super 
							end
						end
						@enumerated_attribute_define_once_only = true
					
						alias_method :respond_to_without_enumerated_attribute?, :respond_to?
						def respond_to?(method)
							respond_to_without_enumerated_attribute?(method) || (!!parse_dynamic_method_parts!(method.to_s) rescue false)
						end
						
						def initialize_enumerated_attributes(only_if_nil = false)
							self.class.enumerated_attribute_initial_value_list.each do |k,v|
								self.write_enumerated_attribute(k, v) unless (only_if_nil && read_enumerated_attribute(k) != nil)
							end
						end

						private
						
						def parse_dynamic_method_parts!(meth_name)
							return(nil) unless meth_name[-1, 1] == '?'
							
							middle = meth_name.chop #remove the ?
							
							attr = nil
							@@enumerated_attribute_names.each do |name|
								if middle.sub!(Regexp.new("^"+name.to_s), "")
									attr = name; break
								end
							end
							
							value = nil
							attr_sym = attr ? attr.to_sym : nil
							if (enum_values = @@enumerated_attribute_values[attr_sym] )	#nil if [nil]
								enum_values.each do |v|
									if middle.sub!(Regexp.new(v.to_s+"$"), "")
										value = v; break
									end
								end	
							else
								#search through enum values one at time and identify any ambiguities
								@@enumerated_attribute_values.each do |attr_key,enums|
									enums.each do|v|
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
				METHOD

				#create state and action methods from block
				initial_value = opts[:init] || initial_value  
				if block_given?
					m = EnumeratedAttribute::MethodDefinitionDSL.new(self, attr_name, enums)
					m.instance_eval(&block)
					initial_value = m.initial_value || initial_value
					plural_name = m.pluralized_name || plural_name
					decrementor = m.decrementor_name || decrementor
					incrementor = m.incrementor_name || incrementor
				end

				#define the enum values accessor
				class_eval <<-ENUM
					def #{plural_name}
						@@enumerated_attribute_values[:#{attr_name}]
					end
					def #{incrementor}
						z = @@enumerated_attribute_values[:#{attr_name}]
						index = z.index(@#{attr_name})
						write_enumerated_attribute(:#{attr_name}, z[index >= z.size-1 ? 0 : index+1])
					end
					def #{decrementor}
						z = @@enumerated_attribute_values[:#{attr_name}]
						index = z.index(@#{attr_name})
						write_enumerated_attribute(:#{attr_name}, z[index > 0 ? index-1 : z.size-1])
					end
				ENUM
				
				unless @enumerated_attribute_init
					define_enumerated_attribute_new_method
				end
				@enumerated_attribute_init ||= {}		
				if (initial_value = opts[:init] || initial_value)
					@enumerated_attribute_init[attr_sym] = initial_value 
				end
				class_eval do
					class << self
						def enumerated_attribute_initial_value_list; @enumerated_attribute_init; end
					end
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
