require "test/unit"
require "fileutils"
require "json"

##
# Module to include in tests that provides helper functions.
module TestHelper
  ##
  # Reads the fixtures in as a hash.
  #
  # @return [Hash]
  def fixtures
    @fixtures ||= JSON.parse(File.read(File.join(__dir__, "fixtures.json")))
  end

  def reset_spoonerize_config
    Spoonerize.reset_config
    Spoonerize.instance_variable_set("@config_file_loaded", false)
  end

  def spoonerism(words, **opts)
    reset_spoonerize_config
    opts.each { |k, v| Spoonerize.config.public_send(:"#{k}=", v) }
    Spoonerize::Spoonerism.new(words)
  end

  def test_log_directory
    @tld ||= File.join(__dir__, "log")
  end

  def test_log_file
    @tlf ||= File.join(test_log_directory, "spoonerize.csv")
  end

  ##
  # Creates instance of +Cli+.
  #
  # @param [Array] options Parsed by +getopts+
  #
  # @return [Spoonerize::Cli]
  def cli(options = [])
    Spoonerize::Cli.new(fixtures["default_words"] + options)
  end

  def create_log_file
    FileUtils.mkdir(test_log_directory) unless File.directory?(test_log_directory)
    File.open(test_log_file, "w+") do |line|
      fixtures["log_output"].each { |o| line.puts o }
    end
  end

  ##
  # Creates a config file.
  #
  # @param [String] file The file to create
  def create_config_file(file)
    dir = File.dirname(file)
    FileUtils.mkdir(dir) unless File.directory?(dir)
    File.open(file, "w+") do |f|
      f.puts <<~RUBY
        Spoonerize.configure do |config|
          config.reverse = true
        end
      RUBY
    end
  end
end
