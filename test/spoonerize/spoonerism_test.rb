require_relative "../test_helper"
require_relative "../../lib/spoonerize"

##
# The test suite for +Spoonerism+.
class TestSpoonerism < Test::Unit::TestCase
  include TestHelper

  def setup
    @workdir = File.join(__dir__, "files")
    @test_config = File.join(@workdir, "spoonerizerc")
    reset_spoonerize_config
  end

  def teardown
    FileUtils.rm_f(@test_config)
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  def test_initialize
    assert_nothing_raised { Spoonerize::Spoonerism.new(%w[test]) }
    assert_nothing_raised { Spoonerize::Spoonerism.new(%w[the ultimate spoonerize test]) }
  end

  def test_spoonerize
    assert_raise("Spoonerize::JakPibError") do
      spoonerism(%w[test]).spoonerize
    end

    assert_raise("Spoonerize::JakPibError") do
      spoonerism(%w[hello]).spoonerize
    end

    assert_raise("Spoonerize::JakPibError") do
      spoonerism(%w[his and hers], lazy: true).spoonerize
    end

    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal(%w[e spultimate toonerize thest], s.spoonerize)
  end

  def test_words
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal(%w[the ultimate spoonerize test], s.words)
  end

  def test_reverse
    s = spoonerism(%w[the ultimate spoonerize test])
    refute(Spoonerize.config.reverse)
    assert_nothing_raised { Spoonerize.config.reverse = true }
    assert(Spoonerize.config.reverse)
    assert_equal(%w[te thultimate oonerize spest], s.spoonerize)
  end

  def test_lazy
    s = spoonerism(%w[the ultimate spoonerize test])
    refute(Spoonerize.config.lazy)
    assert_nothing_raised { Spoonerize.config.lazy = true }
    assert(Spoonerize.config.lazy)
    assert_equal(%w[the spultimate toonerize est], s.spoonerize)
  end

  def test_to_s
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal("e spultimate toonerize thest", s.to_s)
  end

  def test_to_h
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal({
      "the" => "e",
      "ultimate" => "spultimate",
      "spoonerize" => "toonerize",
      "test" => "thest"
    }, s.to_h)
  end

  def test_to_json
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal({
      "the"        => "e",
      "ultimate"   => "spultimate",
      "spoonerize" => "toonerize",
      "test"       => "thest"
    }.to_json, s.to_json)
  end

  def test_enough_flippable_words?
    s = spoonerism(%w[test])
    refute(s.enough_flippable_words?)

    s = spoonerism(%w[the ultimate spoonerize test])
    assert(s.enough_flippable_words?)
  end

  def test_save
    s = spoonerism(%w[the ultimate spoonerize test], logfile_name: test_log_file)
    assert_nothing_raised { s.save }
    assert(File.directory?(test_log_directory))
    assert(File.file?(test_log_file))
  end

  def test_excluded_words
    assert_empty(Spoonerize.config.excluded_words)
    assert_nothing_raised { Spoonerize.config.excluded_words = %w[test] }
    assert_equal(%w[test], Spoonerize.config.excluded_words)
    assert_nothing_raised { Spoonerize.config.excluded_words << "ultimate" }
    assert_equal(%w[test ultimate], Spoonerize.config.excluded_words)
  end

  def test_all_excluded_words
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_empty(s.all_excluded_words)
    Spoonerize.config.lazy = true
    assert_equal(fixtures["lazy_words"], s.all_excluded_words)
    assert_nothing_raised { Spoonerize.config.excluded_words = %w[test] }
    assert_equal(%w[test] + fixtures["lazy_words"], s.all_excluded_words)
    assert_nothing_raised { Spoonerize.config.excluded_words << "ultimate" }
    assert_equal(%w[test ultimate] + fixtures["lazy_words"], s.all_excluded_words)
  end

  def test_logfile_name
    assert_equal(
      File.join(ENV["HOME"], ".cache", "spoonerize", "spoonerize.csv"),
      Spoonerize.config.logfile_name
    )
    assert_nothing_raised { Spoonerize.config.logfile_name = test_log_file }
    assert_equal(test_log_file, Spoonerize.config.logfile_name)
  end

  ##
  # Should be false until config file is loaded.
  def test_config_file_loaded?
    refute(Spoonerize.config_file_loaded?)

    create_config_file(@test_config)
    assert_nothing_raised { Spoonerize.load_config_file(@test_config) }
    assert(Spoonerize.config_file_loaded?)
  end

  ##
  # Config file should update global config when loaded.
  def test_load_config_file_updates_config
    create_config_file(@test_config)
    refute(Spoonerize.config.reverse)
    assert_nothing_raised { Spoonerize.load_config_file(@test_config) }
    assert(Spoonerize.config.reverse)
  end

  ##
  # Should raise if file doesn't exist.
  def test_load_config_file
    assert_raise { Spoonerize.load_config_file(@test_config) }
    create_config_file(@test_config)
    assert_nothing_raised { Spoonerize.load_config_file(@test_config) }
  end
end
