require "yaml"
require_relative "spoonerize/spoonerism"
require_relative "spoonerize/bumper"
require_relative "spoonerize/version"
require_relative "spoonerize/log"
require_relative "spoonerize/cli"

##
# The main namespace for the gem.
module Spoonerize
  ##
  # The error exception raised when there are not enough flippable words.
  JakPibError = Class.new(StandardError)

  ##
  # Excluded words from config files.
  LAZY_WORDS = YAML.load_file(
    File.join(File.dirname(__FILE__), "config", "lazy_words.yml")
  ).freeze
end
