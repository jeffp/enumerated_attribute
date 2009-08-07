# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{enumerated_attribute}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff Patmon"]
  s.date = %q{2009-08-06}
  s.description = %q{Enumerated model attributes and view helpers}
  s.email = %q{jpatmon@gmail.com}
  s.files = ["lib/enumerated_attribute", "lib/enumerated_attribute/attribute", "lib/enumerated_attribute/attribute/attribute_descriptor.rb", "lib/enumerated_attribute/attribute.rb", "lib/enumerated_attribute/integrations", "lib/enumerated_attribute/integrations/active_record.rb", "lib/enumerated_attribute/integrations/datamapper.rb", "lib/enumerated_attribute/integrations/default.rb", "lib/enumerated_attribute/integrations/object.rb", "lib/enumerated_attribute/integrations.rb", "lib/enumerated_attribute/method_definition_dsl.rb", "lib/enumerated_attribute/rails_helpers.rb", "lib/enumerated_attribute.rb", "spec/active_record", "spec/active_record/active_record_spec.rb", "spec/active_record/associations_spec.rb", "spec/active_record/association_test_classes.rb", "spec/active_record/cfg.rb", "spec/active_record/race_car.rb", "spec/active_record/single_table_inheritance_spec.rb", "spec/active_record/test_in_memory.rb", "spec/car.rb", "spec/cfg.rb", "spec/new_and_method_missing_spec.rb", "spec/plural.rb", "spec/poro_spec.rb", "spec/rails", "spec/rails/app", "spec/rails/app/controllers", "spec/rails/app/controllers/application_controller.rb", "spec/rails/app/controllers/form_test_controller.rb", "spec/rails/app/helpers", "spec/rails/app/helpers/application_helper.rb", "spec/rails/app/helpers/form_test_helper.rb", "spec/rails/app/models", "spec/rails/app/models/user.rb", "spec/rails/app/views", "spec/rails/app/views/form_test", "spec/rails/app/views/form_test/form.html.erb", "spec/rails/app/views/form_test/form_for.html.erb", "spec/rails/app/views/form_test/form_tag.html.erb", "spec/rails/app/views/form_test/index.html.erb", "spec/rails/app/views/layouts", "spec/rails/app/views/layouts/application.html.erb", "spec/rails/config", "spec/rails/config/boot.rb", "spec/rails/config/database.yml", "spec/rails/config/environment.rb", "spec/rails/config/environments", "spec/rails/config/environments/development.rb", "spec/rails/config/environments/production.rb", "spec/rails/config/environments/test.rb", "spec/rails/config/initializers", "spec/rails/config/initializers/backtrace_silencers.rb", "spec/rails/config/initializers/inflections.rb", "spec/rails/config/initializers/mime_types.rb", "spec/rails/config/initializers/new_rails_defaults.rb", "spec/rails/config/initializers/session_store.rb", "spec/rails/config/locales", "spec/rails/config/locales/en.yml", "spec/rails/config/routes.rb", "spec/rails/db", "spec/rails/db/development.sqlite3", "spec/rails/db/migrate", "spec/rails/db/migrate/20090804230221_create_sessions.rb", "spec/rails/db/migrate/20090804230546_create_users.rb", "spec/rails/db/schema.rb", "spec/rails/db/test.sqlite3", "spec/rails/public", "spec/rails/public/404.html", "spec/rails/public/422.html", "spec/rails/public/500.html", "spec/rails/public/favicon.ico", "spec/rails/public/images", "spec/rails/public/images/rails.png", "spec/rails/public/index.html", "spec/rails/public/javascripts", "spec/rails/public/javascripts/application.js", "spec/rails/public/javascripts/controls.js", "spec/rails/public/javascripts/dragdrop.js", "spec/rails/public/javascripts/effects.js", "spec/rails/public/javascripts/prototype.js", "spec/rails/public/robots.txt", "spec/rails/public/stylesheets", "spec/rails/public/stylesheets/scaffold.css", "spec/rails/Rakefile", "spec/rails/README", "spec/rails/script", "spec/rails/script/about", "spec/rails/script/autospec", "spec/rails/script/console", "spec/rails/script/dbconsole", "spec/rails/script/destroy", "spec/rails/script/generate", "spec/rails/script/performance", "spec/rails/script/performance/benchmarker", "spec/rails/script/performance/profiler", "spec/rails/script/plugin", "spec/rails/script/runner", "spec/rails/script/server", "spec/rails/script/spec", "spec/rails/script/spec_server", "spec/rails/spec", "spec/rails/spec/controllers", "spec/rails/spec/controllers/form_test_controller_spec.rb", "spec/rails/spec/integrations", "spec/rails/spec/integrations/enum_select_spec.rb", "spec/rails/spec/matchers.rb", "spec/rails/spec/rcov.opts", "spec/rails/spec/spec.opts", "spec/rails/spec/spec_helper.rb", "spec/rails/spec/views", "spec/rails/spec/views/form_test", "spec/rails/spec/views/form_test/form.html.erb_spec.rb", "spec/rails/spec/views/form_test/form_for.html.erb_spec.rb", "spec/rails/spec/views/form_test/form_tag.html.erb_spec.rb", "spec/rcov.opts", "spec/spec.opts", "spec/tractor.rb", "CHANGELOG.rdoc", "init.rb", "LICENSE", "Rakefile", "README.rdoc", ".gitignore"]
  s.homepage = %q{http://github.com/jeffp/enumerated_attribute/tree/master}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{Add enumerated attributes to your models and expose them in drop-down lists in your views}
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
