require_relative "../../lib/spoonerize"
require_relative "../test_helper"

##
# The test suite for +Cli+.
class TestCli < Test::Unit::TestCase
  include TestHelper

  ##
  # Destroy the working directory and its contents.
  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  ##
  # The user's preference file is a string.
  def test_PREFERENCE_FILE
    assert_equal(
      File.expand_path(File.join(ENV["HOME"], ".spoonerize.yml")),
      Spoonerize::Cli::PREFERENCE_FILE
    )
  end

  ##
  # The +execute+ method is the entry point for the Cli. It's parameter is an
  # array of command-line flags
  def test_self_execute
    assert_nothing_raised { Spoonerize::Cli.execute(fixtures["default_words"]) }
  end

  ##
  # The +options+ should be an array of options passed from the command line.
  def test_options
    c = cli
    assert_equal(fixtures["default_words"], c.options)
  end

  ##
  # The +preferences+ are the settings after +options+ are parsed.
  def test_preferences
    c = cli(["-m"])
    assert(c.map?)
    refute(c.print?)
    refute(c.save?)
  end

  ##
  # The +initialize+ method should accept the same parameters as +exectute+.
  def test_initialize
    assert_nothing_raised { Spoonerize::Cli.new(fixtures["default_words"]) }
  end

  ##
  # Creates the instance of +Spoonerism+.
  def test_spoonerism
    c = cli
    assert_instance_of(Spoonerize::Spoonerism, c.spoonerism)
  end

  ##
  # False by default. True if flag is passed.
  def test_save?
    c = cli
    refute(c.save?)

    c = cli(["-s"])
    assert(c.save?)
  end

  ##
  # False by default. True if flag is passed.
  def test_print?
    c = cli
    refute(c.print?)

    c = cli(["-p"])
    assert(c.print?)
  end

  ##
  # False by default. True if flag is passed.
  def test_map?
    c = cli
    refute(c.map?)

    c = cli(["-m"])
    assert(c.map?)
  end

  def test_longest_word_length
    c = cli
    assert_equal(8, c.longest_word_length)
  end
end
