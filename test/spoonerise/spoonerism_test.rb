require_relative '../test_helper'
require_relative '../../lib/spoonerise'

##
# The test suite for +Spoonerism+.
class TestSpoonerism < Test::Unit::TestCase
  include TestHelper
  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  def test_initialize
    assert_nothing_raised { Spoonerise::Spoonerism.new(%w[test]) }
    assert_nothing_raised { Spoonerise::Spoonerism.new(%w[the ultimate spoonerise test]) }
  end

  def test_spoonerise
    assert_raise('Spoonerise::JakPibError') do
      spoonerism(%w[test]).spoonerise
    end

    assert_raise('Spoonerise::JakPibError') do
      spoonerism(%w[hello]).spoonerise
    end

    assert_raise('Spoonerise::JakPibError') do
      spoonerism(%w[his and hers], lazy: true).spoonerise
    end

    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal(%w[e spultimate toonerise thest], s.spoonerise)
  end

  def test_words
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal(%w[the ultimate spoonerise test], s.words)
  end

  def test_reverse
    s = spoonerism(%w[the ultimate spoonerise test])
    refute(s.reverse?)
    assert_nothing_raised { s.reverse = true }
    assert(s.reverse?)
    assert_equal(%w[te thultimate oonerise spest], s.spoonerise)
  end

  def test_lazy
    s = spoonerism(%w[the ultimate spoonerise test])
    refute(s.lazy?)
    assert_nothing_raised { s.lazy = true }
    assert(s.lazy?)
    assert_equal(%w[the spultimate toonerise est], s.spoonerise)
  end

  def test_to_s
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal('e spultimate toonerise thest', s.to_s)
  end

  def test_to_h
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal({
      'the'        => 'e',
      'ultimate'   => 'spultimate',
      'spoonerise' => 'toonerise',
      'test'       => 'thest'
    }, s.to_h)
  end

  def test_to_json
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal({
      'the'        => 'e',
      'ultimate'   => 'spultimate',
      'spoonerise' => 'toonerise',
      'test'       => 'thest'
    }.to_json, s.to_json)
  end

  def test_enough_flippable_words?
    s = spoonerism(%w[test])
    refute(s.enough_flippable_words?)

    s = spoonerism(%w[the ultimate spoonerise test])
    assert(s.enough_flippable_words?)
  end

  def test_save
    s = spoonerism(%w[the ultimate spoonerise test], logfile_name: test_log_file)
    assert_nothing_raised { s.save }
    assert(File.directory?(test_log_directory))
    assert(File.file?(test_log_file))
  end

  def test_excluded_words
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_empty(s.excluded_words)
    assert_nothing_raised { s.excluded_words = %w[test] }
    assert_equal(%w[test], s.excluded_words)
    assert_nothing_raised { s.excluded_words << 'ultimate' }
    assert_equal(%w[test ultimate], s.excluded_words)
  end

  def test_all_excluded_words
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_empty(s.all_excluded_words)
    s.lazy = true
    assert_equal(fixtures['lazy_words'], s.all_excluded_words)
    assert_nothing_raised { s.excluded_words = %w[test] }
    assert_equal(%w[test] + fixtures['lazy_words'], s.all_excluded_words)
    assert_nothing_raised { s.excluded_words << 'ultimate' }
    assert_equal(%w[test ultimate] + fixtures['lazy_words'], s.all_excluded_words)
  end

  def test_logfile_name
    s = spoonerism(%w[the ultimate spoonerise test])
    assert_equal(
      File.join(ENV['HOME'], '.cache', 'spoonerise', 'spoonerise.csv'),
      s.logfile_name
    )
    assert_nothing_raised { s.logfile_name = test_log_file }
    assert_equal(test_log_file, s.logfile_name)
  end
end
