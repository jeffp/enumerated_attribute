# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enumerated_attribute}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Patmon"]
  s.date = %q{2009-07-08}
  s.description = %q{An attribute accessor which defines enumerated attributes with dynamic method creation for querying attribute state and increasing encapsulation.}
  s.email = %q{jpatmon@gmail.com}
  s.extra_rdoc_files = ["lib/enumerated_attribute.rb", "README.rdoc"]
  s.files = ["enumerated_attribute.gemspec", "lib/enumerated_attribute.rb", "Manifest", "Rakefile", "README.rdoc", "spec/car.rb", "spec/car_spec.rb", "spec/tractor.rb", "spec/tractor_spec.rb"]
  s.homepage = %q{http://github.com/jeffp/enumerated_attribute}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Enumerated_attribute", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{enumerated_attribute}
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{An attribute accessor which defines enumerated attributes with dynamic method creation for querying attribute state and increasing encapsulation.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
