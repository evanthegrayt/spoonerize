require_relative "spoonerize/spoonerism"
require_relative "spoonerize/bumper"
require_relative "spoonerize/config"
require_relative "spoonerize/version"
require_relative "spoonerize/log"
require_relative "spoonerize/cli"

##
# The main namespace for the gem.
module Spoonerize
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
  # @param [String] file
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
