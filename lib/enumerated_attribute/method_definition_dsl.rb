module EnumeratedAttribute

	class MethodDefinition
    attr_accessor :method_name, :negated, :argument    
    
    def initialize(name, arg, negated=false)
      @method_name, @negated, @argument = name, negated, arg
    end
    
    def is_predicate_method?; @method_name[-1, 1] == '?'; end
    def has_method_name?; !!@method_name; end
    def has_argument?; !!@argument; end
  end
  
  class MethodDefinitionDSL
    attr_reader :initial_value, :pluralized_name, :decrementor_name, :incrementor_name
    
    def initialize(class_obj, descriptor)
      @class_obj = class_obj
      @attr_name = descriptor.name
      @attr_descriptor = descriptor #this is the enums array
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
      if (!@attr_descriptor.empty? && !@attr_descriptor.include?(value.to_sym))
        raise(InvalidDefinition, "'#{value}' in method 'init' is not an enumeration value for :#{@attr_name} attribute", caller) 
      end
      @initial_value = value
    end

    def decrementor(value); @decrementor_name = value; end
    def incrementor(value); @incrementor_name = value; end    
    def enums_accessor(value); @pluralized_name = value; end
    alias_method :inc, :incrementor
    alias_method :dec, :decrementor
    alias_method :enums, :enums_accessor
    alias_method :plural, :enums_accessor
		
		def label(hash)
			raise(InvalidDefinition, "label or labels keyword should be followed by a hash of :enum_value=>'label'", caller) unless hash.is_a?(Hash)
			hash.each do |k,v|
				raise(InvalidDefinition, "#{k} is not an enumeration value for :#{@attr_name} attribute", caller) unless (k.is_a?(Symbol) && @attr_descriptor.include?(k))
				raise(InvalidDefinition, "#{v} is not a string. Labels should be strings", caller) unless v.is_a?(String)
				@attr_descriptor.set_label(k, v)
			end
		end
		alias_method :labels, :label
    
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
      if (!@attr_descriptor.empty? && !@attr_descriptor.include?(mdef.argument.to_sym))
        raise(InvalidDefinition, "'#{mdef.argument}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
      end
      @class_obj.class_eval("def #{mdef.method_name}; @#{@attr_name} #{mdef.negated ? '!=' : '=='} :#{mdef.argument}; end") 
    end

    def create_custom_method_for_array_of_enums(mdef)
      if !@attr_descriptor.empty?
        mdef.argument.each do |m|
          if !@attr_descriptor.include?(m.to_sym)
            raise(InvalidDefinition, "'#{m}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
          end
        end
      end
      @class_obj.class_eval("def #{mdef.method_name}; #{mdef.negated ? '!' : ''}[:#{mdef.argument.join(',:')}].include?(@#{@attr_name}); end")
    end
  end
	
end