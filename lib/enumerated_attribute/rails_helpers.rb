
if defined?(ActiveRecord)
	module ActiveRecord
		module ConnectionAdapters
			class TableDefinition
				def column_with_enumerated_attribute(name, type, options = {})
					type = 'string' if type.to_s == 'enum'
					column_without_enumerated_attribute(name, type, options)
				end
				alias_method_chain :column, :enumerated_attribute
				
				def enum(*args)
					options = args.extract_options!                                      
					column_names = args                                                   
					column_names.each { |name| column(name, 'string', options) }  
				end
			end
		end
	end
end

#ARGV is used by generators -- if it contains one of these generator commands - add enumeration support
#unless ((ARGV || []) & ["scaffold", "rspec_scaffold", "nifty_scaffold"]).empty?
if ((ARGV || []).any?{|o| o =~ /scaffold/ })
	require 'rails_generator'
	module Rails
		module Generator
			class GeneratedAttribute
				def field_type_with_enumerated_attribute
					return (@field_type = :enum_select) if type == :enum
					field_type_without_enumerated_attribute
				end
				alias_method_chain :field_type, :enumerated_attribute
			end
		end
	end
end

if defined?(ActionView::Base)
	module ActionView
		module Helpers
		
			#form_options_helper.rb
			module FormOptionsHelper
				#def select
				def enum_select(object, method, options={}, html_options={})
					InstanceTag.new(object, method, self, options.delete(:object)).to_enum_select_tag(options, html_options)
				end
			end
			
			class InstanceTag
				def to_enum_select_tag(options, html_options={})
					choices = []
					if self.object.respond_to?(:enums)
						enums = self.object.enums(method_name.to_sym)
						choices = enums ? enums.select_options : []
						if (value = self.object.__send__(method_name.to_sym))
							options[:selected] ||= value.to_s
						else
              options[:include_blank] = enums.allows_nil? if options[:include_blank].nil?
						end
					end
					to_select_tag(choices, options, html_options)
				end
				
				#initialize record_name, method, self
				def to_tag_with_enumerated_attribute(options={})
					#look for an enum
					if (column_type == :string && 
						self.object.class.respond_to?(:has_enumerated_attribute?) &&
						self.object.class.has_enumerated_attribute?(method_name.to_sym)) 
						to_enum_select_tag(options)
					else
						to_tag_without_enumerated_attribute(options)
					end
				end
				alias_method_chain :to_tag, :enumerated_attribute
			end
			
			class FormBuilder
				def enum_select(method, options={}, html_options={})
					@template.enum_select(@object_name, method, objectify_options(options), @default_options.merge(html_options))
				end
			end
			
		end
	end
end


