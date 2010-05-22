require 'enumerated_attribute/attribute/attribute_descriptor'
require 'enumerated_attribute/attribute/arguments'
require 'enumerated_attribute/attribute/instance_methods'
require 'enumerated_attribute/attribute/class_methods'
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

    def create_enumerated_attribute(*args, &block)
      return if args.empty?
      config = Arguments.parse_enum_attr_arguments(args)

      class_eval do
        @enumerated_attributes ||= {}
        @enumerated_attributes[config.attr_symbol] = AttributeDescriptor.new(config.attr_symbol, config.enums, config.opts)

        unless @integration_map
          @integration_map = Integrations.find_integration_map(self)
          @integration_map[:aliasing].each do |p|
            alias_method(p.first, p.last)
          end
          include(EnumeratedAttribute::Integrations::Default)
          include(@integration_map[:module]) if @integration_map[:module]

          self.extend ClassMethods
          include InstanceMethods
        end
      end

      #create accessors
      define_enumerated_attribute_reader_method(config.attr_symbol) unless (config.opts.key?(:reader) && !config.opts[:reader])
      define_enumerated_attribute_writer_method(config.attr_symbol) unless (config.opts.key?(:writer) && !config.opts[:writer])
      define_enumerated_attribute_new_method

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
        @enumerated_attributes ||={}
        @enumerated_attributes[config.attr_symbol].init_value = config.initial_value if config.initial_value

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
    end
  end
		
end
