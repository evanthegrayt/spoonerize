require_relative '../lib/spoonerize'
require_relative 'test_helper'

##
# The test suite for +Spoonerize+.
class TestSpoonerize < Test::Unit::TestCase
  include TestHelper

  def test_LAZY_WORDS
    assert_equal(fixtures['lazy_words'], Spoonerize::LAZY_WORDS)
  end

  ##
  # +Spoonerize::VERSION+ should consist of three integers separated by dots.
  def test_VERSION
    assert_match(/\d+\.\d+.\d+/, ::Spoonerize::VERSION)
  end
end
