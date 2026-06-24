# frozen_string_literal: true

##
# The main namespace for the gem.
module Spoonerize
  ##
  # The config file the user can create to change default runtime options.
  #
  # @return [String]
  CONFIG_FILE = File.expand_path(File.join(ENV["HOME"], ".spoonerizerc"))
end

require_relative "spoonerize/config"
require_relative "spoonerize/spoonerism"
require_relative "spoonerize/bumper"
require_relative "spoonerize/version"
require_relative "spoonerize/log"
require_relative "spoonerize/cli"

##
# The main namespace for the gem.
module Spoonerize
  ##
  # Has the config file been loaded?
  @config_file_loaded = false

  module_function

  ##
  # Method for accessing the configuration.
  #
  # @return [Spoonerize::Config]
  def config
    @config || reset_config
  end

  ##
  # Reset all configuration values to their defaults.
  #
  # @return [Spoonerize::Config]
  def reset_config
    @config_file_loaded = false
    @config = Spoonerize::Config.new
  end

  ##
  # Allows for configuration via a block. Useful when making config files.
  #
  # @example
  #   Spoonerize.configure { |s| s.lazy = true }
  def configure
    yield config
  end

  ##
  # Has a config file been loaded?
  #
  # @return [Boolean]
  def config_file_loaded?
    @config_file_loaded
  end

  ##
  # Loads a config file.
  #
  # @param [String] config_file
  #
  # @return [String] file
  def load_config_file(config_file)
    ::File.expand_path(config_file).tap do |file|
      raise "File #{file} does not exist." unless ::File.file?(file)

      @config_file_loaded = true
      load file
    end
  end
end
