# frozen_string_literal: true

require_relative "lib/spoonerize"
require "bundler/gem_tasks"
require "rdoc/task"
require "rake/testtask"
require "semverve/task"
require "standard/rake"

Semverve::Task.new do |t|
  t.bundle_lock = true
end

Rake::TestTask.new do |t|
  t.libs = ["lib"]
  t.warning = true
  t.verbose = true
  t.test_files = FileList["test/**/*_test.rb"]
end

RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "docs"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

task default: :test
