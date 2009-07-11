module EnumeratedAttribute

#todo: is_not/is -- test raised errors contain useful info on invalid syntax
#todo: dynamic_enums
#todo: system wide constants
#todo: setter_callback
#todo: ArgumentError may need to use Errors for ActiveRecord
#todo: test new chaining plays nice
#todo: attribute methods gear.enums, gear.inc, gear.dec

  def enum_attr_reader(*args, &block)
    if args.length > 1
      args << {} if args.length == 2
      args[2][:writer] = false if args[2].kind_of?(Hash)
    end
    enumerated_attribute(*args, &block)
  end
  def enum_attr_writer(*args, &block)
    if args.length > 1
      args << {} if args.length == 2
      args[2][:reader] = false if args[2].kind_of?(Hash)
    end
    enumerated_attribute(*args, &block)
  end
  
  def enumerated_attribute(*args, &block)
    return if args.empty?
    attr_name = args[0].to_s
    attr_sym = attr_name.to_sym
    enums = (args[1] && args[1].instance_of?(Array) ? args[1] : [])
    index = enums.empty? ? 1 : 2
    opts = (args[index] && args[index].instance_of?(Hash) ? args[index] : {})
    
    raise(ArgumentError, 'second argument of enumerated_attribute/enum_attr is not an array of symbols or strings representing the enum values', caller) if enums.empty?

    #todo: better pluralization of attribute
    initial_value = nil
    plural_name = opts[:plural] || opts[:enums_accessor] || opts[:enums] || "#{attr_name}s"
    incrementor = opts[:incrementor] || opts[:inc] || "#{attr_name}_next"
    decrementor = opts[:decrementor] || opts[:dec] || "#{attr_name}_previous"
    
    class_eval <<-ATTRIB
      @@enumerated_attribute_names ||= []
      @@enumerated_attribute_names << '#{attr_name}'
    ATTRIB
    
    unless enums.empty?
      enums = enums.map{|v| (v =~ /^\^/ ? (initial_value = v[1, v.length-1].to_sym) : v.to_sym )}
      class_eval <<-ENUMS
        @@enumerated_attribute_values ||= {}
        @@enumerated_attribute_values[:#{attr_name}] = [:#{enums.join(',:')}]
      ENUMS
    end

    #create accessors
    attr_reader attr_sym unless (opts.key?(:reader) && !opts[:reader])
    unless (opts.key?(:writer) && !opts[:writer])
      if enums.empty?
        attr_writer attr_sym 
      else
        enumerated_attr_writer(attr_sym, opts[:nil] || false)
      end
    end
    
    #define dynamic methods in method_missing
    class_eval <<-METHOD
      unless @missing_method_for_enumerated_attribute_defined
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
        @missing_method_for_enumerated_attribute_defined = true
      
        alias_method :respond_to_without_enumerated_attribute?, :respond_to?
        def respond_to?(method)
          respond_to_without_enumerated_attribute?(method) || !!parse_dynamic_method_parts(method.to_s)
        end
        
        private
        
        def parse_dynamic_method_parts(meth_name)
          return(nil) unless meth_name[-1, 1] == '?'
          
          meth_name.chop! #remove the ?
          
          attr = nil
          @@enumerated_attribute_names.each do |name|
            if meth_name.sub!(Regexp.new("^"+name.to_s), "")
              attr = name; break
            end
          end
          return (nil) unless attr
          attr_sym = attr.to_sym
          
          value = nil
          if @@enumerated_attribute_values.key?(attr_sym)
            @@enumerated_attribute_values[attr_sym].each do |v|
              if meth_name.sub!(Regexp.new(v.to_s+"$"), "")
                value = v; break
              end
            end
          end
          return (nil) unless value
          
          [attr, value, meth_name]
        end
      
        def define_enumerated_attribute_dynamic_method(methId)
          meth_name = methId.id2name
          return(false) unless (parts = parse_dynamic_method_parts(meth_name))
          return(false) unless parts
          
          negated = !!parts[2].downcase.match(/_not_/)
          self.class.define_attribute_state_method(methId, parts[0], parts[1].to_sym, negated)
          
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
    unless enums.empty?
      class_eval <<-ENUM
        def #{plural_name}
          @@enumerated_attribute_values[:#{attr_name}]
        end
        def #{incrementor}
          z = @@enumerated_attribute_values[:#{attr_name}]
          index = z.index(@#{attr_name})
          @#{attr_name} = z[index >= z.size-1 ? 0 : index+1]
        end
        def #{decrementor}
          z = @@enumerated_attribute_values[:#{attr_name}]
          index = z.index(@#{attr_name})
          @#{attr_name} = z[index > 0 ? index-1 : z.size-1]
        end
        def #{attr_name}_nil?
          @#{attr_name} == nil
        end
      ENUM
    end
    
    #establish initial value
    if (initial_value = opts[:init] || initial_value)
      class_eval <<-INITVAL
        unless @enumerated_attribute_init
          @enumerated_attribute_init = {}
          class << self
            def new_with_enumerated_attribute(*args)
              result = new_without_enumerated_attribute(*args)
              @enumerated_attribute_init.each do |k,v|
                result.instance_variable_set("@"+k.to_s, v)
              end
              result
            end
            alias_method :new_without_enumerated_attribute, :new
            alias_method :new, :new_with_enumerated_attribute
          end
        end
        @enumerated_attribute_init[:#{attr_name}] = :#{initial_value}
      INITVAL
    end
    
  end

  #a short cut
  alias :enum_attr :enumerated_attribute
  
  def define_attribute_state_method(symbol, attr_name, value, negated)
    define_method symbol do
      ival = instance_variable_get('@'+attr_name)
      negated ? ival != value : ival == value
    end
  end

  private
  
  def enumerated_attr_writer name, allow_nil=false
    name = name.to_s
    class_eval <<-METHOD
      def #{name}=(val)        
        val = val.to_sym if val.instance_of?(String)
        unless (val == nil && #{allow_nil})
          raise(ArgumentError, 
            (val == nil ? "nil is not allowed on #{name} attribute, set :nil=>true option" : "'" + val.to_s + "' is not an enumeration value for #{name} attribute"), 
            caller) unless @@enumerated_attribute_values[:#{name}].include?(val) 
        end
        @#{name} = val
      end
    METHOD
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
      arg = args[0] if args.length > 0
      MethodDefinition.new(nil, arg, true)
    end
    alias :isnt :is_not
    
    def is(*args)
      arg = args[0] if args.length > 0
      MethodDefinition.new(nil, arg)
    end

    def method_missing(methId, *args, &block)
      meth_name = methId.id2name
      
      meth_def = nil
      if args.size > 0
        arg = args[0]
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
        raise(NameError, "'#{value}' in method 'init' is not an enumeration value for :#{@attr_name} attribute", caller) 
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
      raise NameError, "'#{meth_name}' should be followed by #{followed_by} -- but #{suffix}"
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
        raise(NameError, "'#{mdef.argument}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
      end
      @class_obj.class_eval("def #{mdef.method_name}; @#{@attr_name} #{mdef.negated ? '!=' : '=='} :#{mdef.argument}; end") 
    end

    def create_custom_method_for_array_of_enums(mdef)
      if !@attr_values.empty?
        mdef.argument.each do |m|
          if !@attr_values.include?(m.to_sym)
            raise(NameError, "'#{m}' in method '#{mdef.method_name}' is not an enumeration value for :#{@attr_name} attribute", caller) 
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


