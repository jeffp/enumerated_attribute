# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enumerated_attribute}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Patmon"]
  s.date = %q{2009-07-11}
  s.description = %q{A enumerated attribute accessor}
  s.email = %q{jpatmon@yahoo.com}
  s.files = ["lib/enumerated_attribute.rb", "spec/car.rb", "spec/car_spec.rb", "spec/tractor.rb", "spec/tractor_spec.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc", ".gitignore"]
  s.homepage = %q{http://www.jpatmon.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Defines enumerated attributes, initial state and dynamic state methods.}
  s.test_files = ["spec/car_spec.rb", "spec/tractor_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
