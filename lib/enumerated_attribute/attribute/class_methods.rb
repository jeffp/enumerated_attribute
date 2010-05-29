module EnumeratedAttribute
  module Attribute
    module ClassMethods
      def refresh_enumerated_attributes
        @all_enumerated_attributes_cache = nil
      end
      def enumerated_attributes(all=true)
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

      def has_enumerated_attribute?(name)
        !name.nil? && !!self.enumerated_attributes.key?(name.to_sym)
      end
      def enumerated_attribute_allows_nil?(name)
        (descriptor = self.enumerated_attributes[name.to_sym]) && descriptor.allows_nil?
      end
      def enumerated_attribute_allows_value?(name, value)
        return (false) unless (descriptor = self.enumerated_attributes[name.to_sym])
        return descriptor.allows_nil? if (value == nil || value == '')
        descriptor.allows_value?(value)
      end

      def define_enumerated_attribute_custom_method(symbol, attr_name, value, negated)
        define_method symbol do
          ival = read_enumerated_attribute(attr_name)
          negated ? ival != value : ival == value
        end
      end

    end
  end
end