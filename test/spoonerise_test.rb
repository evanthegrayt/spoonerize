require_relative '../lib/spoonerise'
require_relative 'test_helper'

##
# The test suite for +Spoonerise+.
class TestSpoonerise < Test::Unit::TestCase
  include TestHelper

  def test_LAZY_WORDS
    assert_equal(fixtures['lazy_words'], Spoonerise::LAZY_WORDS)
  end

  ##
  # +Spoonerise::VERSION+ should consist of three integers separated by dots.
  def test_VERSION
    assert_match(/\d+\.\d+.\d+/, ::Spoonerise::VERSION)
  end
end
