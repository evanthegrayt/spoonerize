require_relative "../../lib/spoonerize"
require_relative "../test_helper"

##
# The test suite for +Cli+.
class TestCli < Test::Unit::TestCase
  include TestHelper

  def setup
    reset_spoonerize_config
  end

  ##
  # Destroy the working directory and its contents.
  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  ##
  # The user's config file is a string.
  def test_CONFIG_FILE
    assert_equal(
      File.expand_path(File.join(ENV["HOME"], ".spoonerizerc")),
      Spoonerize::Cli::CONFIG_FILE
    )
  end

  ##
  # The +execute+ method is the entry point for the Cli. Its parameter is an
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
  # The +overrides+ are the settings after +options+ are parsed.
  def test_overrides
    c = cli(["-m"])
    assert(c.map?)
    refute(c.print_log?)
    refute(c.save?)

    c = cli(["-r", "-l", "-c", "--exclude=ultimate,test"])
    assert_equal({
      reverse: true,
      lazy: true,
      consonants_only: true,
      excluded_words: %w[ultimate test]
    }, c.overrides)
  end

  ##
  # The +initialize+ method should accept the same parameters as +execute+.
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
  def test_print_log?
    c = cli
    refute(c.print_log?)

    c = cli(["-p"])
    assert(c.print_log?)
  end

  ##
  # False by default. True if flag is passed.
  def test_map?
    c = cli
    refute(c.map?)

    c = cli(["-m"])
    assert(c.map?)
  end

  def test_exclude
    assert_empty(Spoonerize.config.excluded_words)

    c = cli(["--exclude=ultimate,test"])
    assert_equal(%w[ultimate test], c.spoonerism.config.excluded_words)
    assert_empty(Spoonerize.config.excluded_words)
  end

  def test_consonants_only
    refute(Spoonerize.config.consonants_only)

    c = cli(["--consonants-only"])
    assert(c.spoonerism.config.consonants_only)
    refute(Spoonerize.config.consonants_only)
  end

  def test_no_consonants_only_overrides_config
    Spoonerize.config.consonants_only = true

    c = cli(["--no-consonants-only"])

    refute(c.spoonerism.config.consonants_only)
    assert(Spoonerize.config.consonants_only)
  end

  def test_cli_options_do_not_mutate_global_config
    assert_equal(false, Spoonerize.config.reverse)
    assert_equal(false, Spoonerize.config.lazy)
    assert_equal(false, Spoonerize.config.consonants_only)
    assert_empty(Spoonerize.config.excluded_words)

    c = cli(["-r", "-l", "-c", "--exclude=ultimate,test"])

    assert_equal(true, c.spoonerism.config.reverse)
    assert_equal(true, c.spoonerism.config.lazy)
    assert_equal(true, c.spoonerism.config.consonants_only)
    assert_equal(%w[ultimate test], c.spoonerism.config.excluded_words)
    assert_equal(false, Spoonerize.config.reverse)
    assert_equal(false, Spoonerize.config.lazy)
    assert_equal(false, Spoonerize.config.consonants_only)
    assert_empty(Spoonerize.config.excluded_words)
  end

  def test_longest_word_length
    c = cli
    assert_equal(10, c.longest_word_length)
  end
end
