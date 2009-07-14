#require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/sshpublisher'
 
spec = Gem::Specification.new do |s|
  s.name = 'enumerated_attribute'
  s.version = '0.1.3'
  s.platform = Gem::Platform::RUBY
  s.description = 'A enumerated attribute accessor'
  s.summary = 'Defines enumerated attributes, initial state and dynamic state methods.'
  
  s.files = FileList['{examples,lib,tasks,spec}/**/*'] + %w(CHANGELOG.rdoc init.rb LICENSE Rakefile README.rdoc .gitignore) - FileList['test/*.log']
  s.require_path = 'lib'
  s.has_rdoc = true
  s.test_files = Dir['spec/*_spec.rb']
  
  s.author = 'Jeff Patmon'
  s.email = 'jpatmon@yahoo.com'
  s.homepage = 'http://www.jpatmon.com'
end
 
require 'spec/version'
require 'spec/rake/spectask'

desc "Run specs"
Spec::Rake::SpecTask.new(:spec) do |t|
	t.spec_files = FileList['spec/*_spec.rb']
	t.libs << 'lib' << 'spec'
	t.rcov = false
	#t.spec_opts = ['--options', 'spec/spec.opts']
	#t.rcov_dir = 'coverage'
	#t.rcov_opts = ['--exclude', "kernel,load-diff-lcs\.rb,instance_exec\.rb,lib/spec.rb,lib/spec/runner.rb,^spec/*,bin/spec,examples,/gems,/Library/Ruby,\.autotest,#{ENV['GEM_HOME']}"]
end

namespace :spec do
  desc "Run ActiveRecord integration specs"
	Spec::Rake::SpecTask.new(:active_record) do |t|
		t.spec_files = FileList['spec/active_record/*_spec.rb']
		t.libs << 'lib' << 'spec/active_record'
		t.rcov = false
	end
	desc "Run all specs"
	task :all=>[:spec, :active_record] 
end

=begin
desc "Test the #{spec.name} plugin."
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.test_files = spec.test_files
  t.verbose = true
end
 
begin
  require 'rcov/rcovtask'
  namespace :test do
    desc "Test the #{spec.name} plugin with Rcov."
    Rcov::RcovTask.new(:rcov) do |t|
      t.libs << 'lib'
      t.test_files = spec.test_files
      t.rcov_opts << '--exclude="^(?!lib/)"'
      t.verbose = true
    end
  end
rescue LoadError
end
=end

desc "Generate documentation for the #{spec.name} plugin."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = spec.name
  #rdoc.template = '../rdoc_template.rb'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc', 'CHANGELOG.rdoc', 'LICENSE', 'lib/**/*.rb')
end
 
desc 'Generate a gemspec file.'
task :gemspec do
  File.open("#{spec.name}.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
end
 
Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Dir['tasks/**/*.rake'].each {|rake| load rake}
