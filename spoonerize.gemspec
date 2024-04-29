require_relative "lib/spoonerize/version"

Gem::Specification.new do |spec|
  spec.name = "spoonerize"
  spec.version = Spoonerize::VERSION
  spec.authors = ["Evan Gray"]
  spec.email = "evanthegrayt@vivaldi.net"
  spec.license = "MIT"

  spec.summary = %(Spoonerize phrases from the command line.)
  spec.description = %(Spoonerize phrases from the command line. Comes with an API)
  spec.homepage = "https://evanthegrayt.github.io/spoonerize/"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/evanthegrayt/spoonerize"
    spec.metadata["documentation_uri"] = "https://evanthegrayt.github.io/spoonerize/"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_development_dependency "rake", "~> 13.0", ">= 13.0.1"
  spec.add_development_dependency "test-unit", "~> 3.3", ">= 3.3.5"
end
