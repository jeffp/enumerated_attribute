require 'enumerated_attribute/integrations/active_record'
require 'enumerated_attribute/integrations/object'
require 'enumerated_attribute/integrations/datamapper'
require 'enumerated_attribute/integrations/default'

module EnumeratedAttribute
	module Integrations

		@@integration_map = {}
		
		def self.add_integration_map(base_klass_name, module_object, aliasing_array=[])
			@@integration_map[base_klass_name] = {:module=>module_object, :aliasing=>aliasing_array}
		end
		class << self
			alias_method(:add, :add_integration_map)
		end
		
		#included mappings
		add('Object', EnumeratedAttribute::Integrations::Object)
		add('ActiveRecord::Base', EnumeratedAttribute::Integrations::ActiveRecord)
		
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
end