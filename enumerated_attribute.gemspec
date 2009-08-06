# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enumerated_attribute}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Patmon"]
  s.date = %q{2009-07-27}
  s.description = %q{An enumerated attribute accessor}
  s.email = %q{jpatmon@yahoo.com}
  s.files = ["lib/enumerated_attribute", "lib/enumerated_attribute/attribute.rb", "lib/enumerated_attribute/integrations", "lib/enumerated_attribute/integrations/active_record.rb", "lib/enumerated_attribute/integrations/datamapper.rb", "lib/enumerated_attribute/integrations/default.rb", "lib/enumerated_attribute/integrations/object.rb", "lib/enumerated_attribute/integrations.rb", "lib/enumerated_attribute/method_definition_dsl.rb", "lib/enumerated_attribute.rb", "spec/active_record", "spec/active_record/active_record_spec.rb", "spec/active_record/cfg.rb", "spec/active_record/race_car.rb", "spec/active_record/single_table_inheritance_spec.rb", "spec/active_record/test_in_memory.rb", "spec/car.rb", "spec/cfg.rb", "spec/new_and_method_missing_spec.rb", "spec/plural.rb", "spec/poro_spec.rb", "spec/tractor.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc", ".gitignore"]
  s.homepage = %q{http://github.com/jeffp/enumerated_attribute/tree/master}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Add enumerated attributes with initialization, dynamic predicate methods, more ...}
  s.test_files = ["spec/new_and_method_missing_spec.rb", "spec/poro_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
