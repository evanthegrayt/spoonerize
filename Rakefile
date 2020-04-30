require_relative 'lib/spoonerise'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = 'doc'
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

task :default => :test

desc "Build the gem"
task :build do
  system('gem build spoonerise.gemspec')
end

desc "Build and install the gem"
task install: [:dependencies, :build] do
  system("gem install spoonerise-#{Spoonerise::VERSION}.gem")
end

desc "Add dependencies"
task :dependencies do
  system("gem install bundler")
  system("bundle install")
end

desc "Uninstall the gem"
task :uninstall do
  system('gem uninstall spoonerise')
end
desc "Run rspec tests"
task :test do
  Dir.glob(File.join(__dir__, 'spec', '**', '*_spec.rb')).each do |file|
    system("rspec #{file}")
  end
end
