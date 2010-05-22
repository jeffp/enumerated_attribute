module EnumeratedAttribute
	module Attribute
    module Arguments
      def self.validate_enum_attr_arguments(config)
				raise(InvalidDefinition, 'second argument of enumerated_attribute/enum_attr is not an array of symbols or strings representing the enum values', caller) if config.enums.empty?
      end
      def self.init_incrementor_decrementor_method_names(config)
				config.incrementor = config.opts[:incrementor] || config.opts[:inc] || "#{config.attr_name}_next"
				config.decrementor = config.opts[:decrementor] || config.opts[:dec] || "#{config.attr_name}_previous"
      end
      def self.init_plural_name(config)
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
      def self.process_enums_for_initial_value(config)
        config.initial_value = nil
				config.enums = config.enums.map{|v| (v =~ /^\^/ ? (config.initial_value ||= v[1, v.length-1].to_sym) : v.to_sym )}
      end

      def self.parse_enum_attr_arguments(args)
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
    end
  end

end