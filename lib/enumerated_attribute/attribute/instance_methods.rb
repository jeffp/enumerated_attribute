module EnumeratedAttribute
  module Attribute
    module InstanceMethods
      def self.included(base)

        method_missing_suffix = "enumerated_attribute_#{base.name}_#{base.hash}".to_sym
        define_method("method_missing_with_#{method_missing_suffix}") do |methId, *args|
          return self.__send__(methId) if define_enumerated_attribute_dynamic_method(methId)
          self.__send__("method_missing_without_#{method_missing_suffix}", methId, *args)
        end

        respond_to_suffix = "enumerated_attribute_#{base.name}_#{base.hash}".to_sym
        define_method("respond_to_with_#{respond_to_suffix}?") do |method|
          self.__send__("respond_to_without_#{respond_to_suffix}?".to_sym, method.to_sym) ||
            (!!parse_dynamic_method_parts!(method.to_s) rescue false)
        end

        base.safe_alias_method_chain :method_missing, method_missing_suffix
        base.safe_alias_method_chain :respond_to?, respond_to_suffix

      end

      def enums(attr)
        self.class.enumerated_attributes[attr.to_sym]
      end


      def initialize_enumerated_attributes(only_if_nil = false)
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
end