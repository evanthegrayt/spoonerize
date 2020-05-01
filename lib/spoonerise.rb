require 'yaml'
require_relative 'spoonerise/spoonerism'
require_relative 'spoonerise/bumper'
require_relative 'spoonerise/version'
require_relative 'spoonerise/log'
require_relative 'spoonerise/cli'

##
# The main namespace for the gem.
module Spoonerise
  ##
  # The error exception raised when there are not enough flippable words.
  JakPibError = Class.new(StandardError)

  ##
  # Excluded words from config files.
  LAZY_WORDS = YAML.load_file(
    File.join(File.dirname(__FILE__), 'config', 'lazy_words.yml')
  ).freeze
end

