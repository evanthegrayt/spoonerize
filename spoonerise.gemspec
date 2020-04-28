require_relative 'lib/spoonerise/version'

Gem::Specification.new do |spec|
  spec.name          = 'spoonerise'
  spec.version       = Spoonerise::VERSION
  spec.authors       = ['Evan Gray']
  spec.email         = 'evanthegrayt@vivaldi.net'
  spec.license       = 'MIT'
  spec.date          = Time.now.strftime('%Y-%m-%d')

  spec.summary       = %q{Spoonerise phrases from the command line.}
  spec.description   = %q{Spoonerise phrases from the command line. Comes with an API}
  spec.homepage      = 'https://evanthegrayt.github.io/spoonerise/'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/evanthegrayt/spoonerise'
    spec.metadata['documentation_uri'] = 'https://evanthegrayt.github.io/spoonerise/doc/index.html'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    # `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.files =       `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
