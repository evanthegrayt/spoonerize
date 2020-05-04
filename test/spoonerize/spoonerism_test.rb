require_relative '../test_helper'
require_relative '../../lib/spoonerize'

##
# The test suite for +Spoonerism+.
class TestSpoonerism < Test::Unit::TestCase
  include TestHelper

  def setup
    @workdir = File.join(__dir__, 'files')
    @test_config = File.join(@workdir, 'spoonerize.yml')
  end

  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  def test_initialize
    assert_nothing_raised { Spoonerize::Spoonerism.new(%w[test]) }
    assert_nothing_raised { Spoonerize::Spoonerism.new(%w[the ultimate spoonerize test]) }
  end

  def test_spoonerize
    assert_raise('Spoonerize::JakPibError') do
      spoonerism(%w[test]).spoonerize
    end

    assert_raise('Spoonerize::JakPibError') do
      spoonerism(%w[hello]).spoonerize
    end

    assert_raise('Spoonerize::JakPibError') do
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
    refute(s.reverse?)
    assert_nothing_raised { s.reverse = true }
    assert(s.reverse?)
    assert_equal(%w[te thultimate oonerize spest], s.spoonerize)
  end

  def test_lazy
    s = spoonerism(%w[the ultimate spoonerize test])
    refute(s.lazy?)
    assert_nothing_raised { s.lazy = true }
    assert(s.lazy?)
    assert_equal(%w[the spultimate toonerize est], s.spoonerize)
  end

  def test_to_s
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal('e spultimate toonerize thest', s.to_s)
  end

  def test_to_h
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal({
      'the'        => 'e',
      'ultimate'   => 'spultimate',
      'spoonerize' => 'toonerize',
      'test'       => 'thest'
    }, s.to_h)
  end

  def test_to_json
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal({
      'the'        => 'e',
      'ultimate'   => 'spultimate',
      'spoonerize' => 'toonerize',
      'test'       => 'thest'
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
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_empty(s.excluded_words)
    assert_nothing_raised { s.excluded_words = %w[test] }
    assert_equal(%w[test], s.excluded_words)
    assert_nothing_raised { s.excluded_words << 'ultimate' }
    assert_equal(%w[test ultimate], s.excluded_words)
  end

  def test_all_excluded_words
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_empty(s.all_excluded_words)
    s.lazy = true
    assert_equal(fixtures['lazy_words'], s.all_excluded_words)
    assert_nothing_raised { s.excluded_words = %w[test] }
    assert_equal(%w[test] + fixtures['lazy_words'], s.all_excluded_words)
    assert_nothing_raised { s.excluded_words << 'ultimate' }
    assert_equal(%w[test ultimate] + fixtures['lazy_words'], s.all_excluded_words)
  end

  def test_logfile_name
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_equal(
      File.join(ENV['HOME'], '.cache', 'spoonerize', 'spoonerize.csv'),
      s.logfile_name
    )
    assert_nothing_raised { s.logfile_name = test_log_file }
    assert_equal(test_log_file, s.logfile_name)
  end

  ##
  # Should be false until config file is loaded.
  def test_config_file_loaded?
    s = spoonerism(%w[the ultimate spoonerize test])
    refute(s.config_file_loaded?)

    create_config_file(@test_config)
    s = ::Spoonerize::Spoonerism.new(%w[the ultimate spoonerize test], @test_config)
    assert_nothing_raised { s.load_config_file }
    assert(s.config_file_loaded?)
  end

  ##
  # Config should be a hash, and populated if +config_file+ is loaded.
  def test_config
    s = spoonerism(%w[the ultimate spoonerize test])
    create_config_file(@test_config)
    assert_empty(s.config)
    assert_nothing_raised { s.config_file = @test_config }
    assert_nothing_raised { s.load_config_file }
    assert_equal({'reverse' => true}, s.config)
    assert(s.reverse?)
  end

  ##
  # Config file should be settable and gettable.
  def test_config_file
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_nil(s.config_file)
    assert_nothing_raised { s.config_file = @test_config }
    assert_equal(@test_config, s.config_file)
  end

  ##
  # Should raise if +config_file+ wasn't set or if file doesn't exist.
  def test_load_config_file
    s = spoonerism(%w[the ultimate spoonerize test])
    assert_raise { s.load_config_file }
    assert_nothing_raised { s.config_file = @test_config }
    create_config_file(@test_config)
    assert_nothing_raised { s.load_config_file }
  end
end
