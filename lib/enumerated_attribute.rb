module EnumeratedAttribute

#todo: is_not/is -- test raised errors contain useful info on invalid syntax
#todo: dynamic_enums
#todo: system wide constants
#todo: setter_callback
#todo: ArgumentError may need to use Errors for ActiveRecord
#todo: attribute methods gear.enums, gear.inc, gear.dec

	class EnumeratedAttributeError < StandardError; end
	class IntegrationError < EnumeratedAttributeError; end
	class InvalidEnumeration < EnumeratedAttributeError; end
	class InvalidDefinition < EnumeratedAttributeError; end

  
  def enumerated_attribute(*args, &block)
    return if args.empty?
    attr_name = args[0].to_s
    attr_sym = attr_name.to_sym
    enums = (args[1] && args[1].instance_of?(Array) ? args[1] : [])
    index = enums.empty? ? 1 : 2
    opts = (args[index] && args[index].instance_of?(Hash) ? args[index] : {})
    
    raise(InvalidDefinition, 'second argument of enumerated_attribute/enum_attr is not an array of symbols or strings representing the enum values', caller) if enums.empty?

    #todo: better pluralization of attribute
    initial_value = nil
    plural_name = opts[:plural] || opts[:enums_accessor] || opts[:enums] || "#{attr_name}s"
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
				include(@integration_map[:module]) if @integration_map[:module]
				
				def has_enumerated_attribute?(name)
					@@enumerated_attribute_names.include?(name.to_s)
				end
				def enumerated_attribute_allows_nil?(name)
					return (false) unless @@enumerated_attribute_options[name.to_sym]
					@@enumerated_attribute_options[name.to_sym][:nil] || false
				end
				def enumerated_attribute_allows_value?(name, value)
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
          respond_to_without_enumerated_attribute?(method) || !!parse_dynamic_method_parts(method.to_s)
        end				
				
				def initialize_enumerated_attributes(only_if_nil = false)
					self.class.enumerated_attribute_initial_value_list.each do |k,v|
						self.write_enumerated_attribute(k, v) unless (only_if_nil && read_enumerated_attribute(k) != nil)
					end
				end

        private
        
        def parse_dynamic_method_parts(meth_name)
          return(nil) unless meth_name[-1, 1] == '?'
          
          middle = meth_name.chop #remove the ?
          
          attr = nil
          @@enumerated_attribute_names.each do |name|
            if middle.sub!(Regexp.new("^"+name.to_s), "")
              attr = name; break
            end
          end
          return (nil) unless attr
          attr_sym = attr.to_sym
          
          value = nil
          if @@enumerated_attribute_values.key?(attr_sym)
            @@enumerated_attribute_values[attr_sym].each do |v|
              if middle.sub!(Regexp.new(v.to_s+"$"), "")
                value = v; break
              end
            end
          end
          unless value #check for nil?
            return (nil) unless middle.sub!(Regexp.new('nil$'), "")
            value = nil
          end
          
          [attr, middle, value]
        end
      
        def define_enumerated_attribute_dynamic_method(methId)
          meth_name = methId.id2name
          return(false) unless (parts = parse_dynamic_method_parts(meth_name))
          
          negated = !!parts[1].downcase.match(/_not_/)
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
	end
	
  #a short cut
  alias :enum_attr :enumerated_attribute
  
  def define_enumerated_attribute_custom_method(symbol, attr_name, value, negated)
    define_method symbol do
      ival = read_enumerated_attribute(attr_name)
      negated ? ival != value : ival == value
    end
  end

  private
	  
	#these implementations are for basic ruby objects - integrations (see Integrations::ActiveRecord) may alter them
	def define_enumerated_attribute_new_method
		class_eval <<-NEWMETH
			class << self
				alias_method :new_without_enumerated_attribute, :new
				def new(*args, &block)
					result = new_without_enumerated_attribute(*args)
					result.initialize_enumerated_attributes
					yield result if block_given?
					result
				end
			end
		NEWMETH
	end
	
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
	
	module Integrations
		module Object
			def self.included(klass)
				klass.extend(ClassMethods)
			end

			def write_enumerated_attribute(name, val)
				name = name.to_s
				val = val.to_sym if val
				unless enumerated_attribute_allows_value?(name, val)
					raise(InvalidEnumeration, "nil is not allowed on '#{name}' attribute, set :nil=>true option", caller) unless val
					raise(InvalidEnumeration, ":#{val} is not a defined enumeration value for the '#{name}' attribute", caller) 
				end
				instance_variable_set('@'+name, val)
			end
			
			def read_enumerated_attribute(name)
				return instance_variable_get('@'+name.to_s)
			end

			module ClassMethods
			end
		
		end
		
		module ActiveRecord
			def self.included(klass)
				klass.extend(ClassMethods)
			end
			
			def write_enumerated_attribute(name, val)
				name = name.to_s
				return write_attribute(name, val) unless self.has_enumerated_attribute?(name)
				val_str = val.to_s if val
				val_sym = val.to_sym if val
				unless enumerated_attribute_allows_value?(name, val_sym)
					raise(InvalidEnumeration, "nil is not allowed on '#{name}' attribute, set :nil=>true option", caller) unless val
					raise(InvalidEnumeration, ":#{val_str} is not a defined enumeration value for the '#{name}' attribute", caller)
				end
				return instance_variable_set('@'+name, val_sym) unless self.has_attribute?(name)
				write_attribute(name, val_str)
			end
			
			def read_enumerated_attribute(name)
				name = name.to_s
				#if not enumerated - let active record handle it
				return read_attribute(name) unless self.has_enumerated_attribute?(name)
				#if enumerated, is it an active record attribute, if not, the value is stored in an instance variable
				return instance_variable_get('@'+name) unless self.has_attribute?(name)
				#this is an enumerated active record attribute
				val = read_attribute(name)
				val = val.to_sym if (!!val && self.has_enumerated_attribute?(name))
				val
			end
			
			def attributes=(attrs, guard_protected_attributes=true)
				return if attrs.nil?
				#check the attributes then turn them over 
				attrs.each do |k, v|
					if has_enumerated_attribute?(k)
						unless enumerated_attribute_allows_value?(k, v)
							raise InvalidEnumeration, ":#{v.to_s} is not a defined enumeration value for the '#{k.to_s}' attribute", caller
						end
						attrs[k] = v.to_s
					end
				end
				#puts "attrs = #{attrs.inspect}"
				
				self.set_active_record_attributes(attrs, guard_protected_attributes)
			end
			
			def attributes
				self.get_active_record_attributes.map do |k,v|
					has_enumerated_attribute?(k) ? v.to_sym : v
				end
			end
			
      def [](attr_name); read_enumerated_attribute(attr_name); end
      def []=(attr_name, value); write_enumerated_attribute(attr_name, value); end
			
=begin			def initialize_enumerated_attributes(only_if_nil = false, only_without_column = false)
				self.class.enumerated_attribute_initial_value_list.each do |k,v|
					unless (only_without_column && has_attribute?(k))
						self.write_enumerated_attribute(k, v) unless (only_if_nil && read_enumerated_attribute(k) != nil)
					end
				end
			end
=end						
			private
						
			def attribute=(attr_name, value); write_enumerated_attribute(attr_name, value); end
									
			module ClassMethods
				private
				
				def instantiate(record)
					object = super(record)
					#object.initialize_enumerated_attributes(false, true)
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
	
		module Datamapper
		end
	
		@@integration_map = {}
		
		def self.add_integration_map(base_klass_name, module_object, aliasing_array=[])
			@@integration_map[base_klass_name] = {:module=>module_object, :aliasing=>aliasing_array}
		end
		class << self
			alias_method(:add, :add_integration_map)
		end
		
		#included mappings
		add('Object', EnumeratedAttribute::Integrations::Object)
		add('ActiveRecord::Base', EnumeratedAttribute::Integrations::ActiveRecord, 
			[	[:set_active_record_attributes, :attributes=],
				[:get_active_record_attributes, :attributes]	])
		
		def self.find_integration_map(klass)
			path = "#{klass}"
			begin
				return @@integration_map[klass.to_s] if @@integration_map.key?(klass.to_s)
				klass = klass.superclass
				path << " < #{klass}"
			end while klass
			raise EnumeratedAttribute::IntegrationError, "Unable to find integration for class hierarchy '#{path}'", caller
		end
		
	end
	
  public
  
  class MethodDefinition
    attr_accessor :method_name, :negated, :argument    
    
    def initialize(name, arg, negated=false)
      @method_name = name
      @negated = negated
      @argument = arg
    end
    
    def is_predicate_method?
      @method_name[-1, 1] == '?'
    end
    def has_method_name?
      !!@method_name
    end
    def has_argument?
      !!@argument
    end    
    
  end
  
  class MethodDefinitionDSL
    attr_reader :initial_value, :pluralized_name, :decrementor_name, :incrementor_name
    
    def initialize(class_obj, attr_name, values=[])
      @class_obj = class_obj
      @attr_name = attr_name
      @attr_values = values      
    end
    
    #we'll by pass this - they can use it if it helps make code more readable - not enforced - should it be??
    def define
    end
    
    def is_not(*args)
      arg = args.first if args.length > 0
      MethodDefinition.new(nil, arg, true)
    end
    alias :isnt :is_not
    
    def is(*args)
      arg = args.first if args.length > 0
      MethodDefinition.new(nil, arg)
    end

    def method_missing(methId, *args, &block)
      meth_name = methId.id2name
      
      meth_def = nil
      if args.size > 0
        arg = args.first
        if arg.instance_of?(EnumeratedAttribute::MethodDefinition)
          if arg.has_method_name?
            raise_method_syntax_error(meth_name, arg.method_name)
          end
          meth_def = arg
          meth_def.method_name = meth_name
        else
          meth_def = MethodDefinition.new(meth_name, arg)
        end
      elsif block_given?
        meth_def = MethodDefinition.new(meth_name, block)
      else
        raise_method_syntax_error(meth_name)
      end
      evaluate_method_definition(meth_def)
    end        
      
     
    def init(value)
      if (!@attr_values.empty? && !@attr_values.include?(value.to_sym))
        raise(InvalidDefinition, "'#{value}' in method 'init' is not an enumeration value for :#{@attr_name} attribute", caller) 
      end
      @initial_value = value
    end

    def decrementor(value); @decrementor_name = value; end
    def incrementor(value); @incrementor_name = value; end    
    def enums_accessor(value); @pluralized_name = value; end
    alias :inc :incrementor
    alias :dec :decrementor
    alias :enums :enums_accessor
    alias :plural :enums_accessor
    
    private
    
    def raise_method_syntax_error(meth_name, offending_token=nil)
      suffix = offending_token ? "found '#{offending_token}'" : "found nothing" 
      followed_by = (meth_name[-1,1] == '?' ? "is_not, an enumeration value, an array of enumeration values, " : "") + "a proc, lambda or code block"
      raise InvalidDefinition, "'#{meth_name}' should be followed by #{followed_by} -- but #{suffix}"
    end
        
    def evaluate_method_definition(mdef)
      unless mdef.has_argument?
        return raise_method_syntax_error(mdef.method_name)
      end
      
      if mdef.is_predicate_method?
        case mdef.argument
          when String
            return create_custom_method_for_symbol_or_string(mdef)
          when Symbol
            return create_custom_method_for_symbol_or_string(mdef)
          when Array
            return create_custom_method_for_array_of_enums(mdef)
          when Proc
            return create_custom_method_for_proc(mdef)            
        end
      else #action method
        if mdef.argument.instance_of?(Proc)
          return create_custom_method_for_proc(mdef)
        end
      end
      raise_method_syntax_error(mdef.method_name, mdef.argument)
    end
    
    def create_custom_method_for_proc(mdef)
      @class_obj.send(:define_method, mdef.method_name, mdef.argument)
    end
    
    def create_custom_method_for_symbol_or_string(mdef)
      if (!@attr_values.empty? && !@attr_values.include?(mdef.argument.to_sym))
        raise(InvalidDefinition, "'#{mdef.argument}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
      end
      @class_obj.class_eval("def #{mdef.method_name}; @#{@attr_name} #{mdef.negated ? '!=' : '=='} :#{mdef.argument}; end") 
    end

    def create_custom_method_for_array_of_enums(mdef)
      if !@attr_values.empty?
        mdef.argument.each do |m|
          if !@attr_values.include?(m.to_sym)
            raise(InvalidDefinition, "'#{m}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
          end
        end
      end
      @class_obj.class_eval("def #{mdef.method_name}; #{mdef.negated ? '!' : ''}[:#{mdef.argument.join(',:')}].include?(@#{@attr_name}); end")
    end
  end  
end

class Class
  include EnumeratedAttribute
end


