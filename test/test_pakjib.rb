require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'pakjib')

class TestPakJib < Test::Unit::TestCase

  def setup
    @tests = {
      normal: %w(This is a test containing lots of words),
      normal_short:  %w(a),
    }
  end

  def teardown
  end

  # TESTS

  def test_initialize
    assert_nothing_raised do
      PakJib.new(@tests[:normal])
    end
    assert_raise PakJib::JakPibError do
      PakJib.new(@tests[:normal_short])
    end
  end

  def test_pakjib_normal
    assert_equal("is tis a cest lontaining ots wof thords",
                 PakJib.new(@tests[:normal]).pakjib.results)
  end

  #def test_pakjib_reverse
    #assert()
  #end

  #def test_pakjib_lazy
    #assert()
  #end

  #def test_pakjib_exclude
    #assert()
  #end

  #def test_words
    #assert()
  #end

end

