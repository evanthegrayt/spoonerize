#===============================================================#
#  File::        spoonerise.rb                                  #
#  Description:: Loads files necessary to run spoonerise        #
#                                                               #
#  Author::      Evan Gray                                      #
#===============================================================#

require 'yaml'
require_relative 'spoonerise/spoonerism'
require_relative 'spoonerise/bumper'
require_relative 'spoonerise/version'

module Spoonerise
  JakPibError = Class.new(StandardError)

  ##
  # Load in excluded words from yaml file as frozen constant
  LAZY_WORDS = YAML.load_file(
    File.join(File.dirname(__FILE__), 'config', 'lazy_words.yml')
  ).freeze
end

