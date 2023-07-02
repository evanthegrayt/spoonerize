# frozen_string_literal: true

module Spoonerize
  ##
  # Module that contains all gem version information. Follows semantic
  # versioning. Read: https://semver.org/
  module Version
    ##
    # Major version.
    MAJOR = 0

    ##
    # Minor version.
    MINOR = 1

    ##
    # Patch version.
    PATCH = 2

    ##
    # Version as +MAJOR.MINOR.PATCH+
    def self.to_s
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end
  end
end
