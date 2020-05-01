require_relative '../lib/spoonerise'
require_relative 'test_helper'

##
# The test suite for +Spoonerise+.
class TestSpoonerise < Test::Unit::TestCase
  include TestHelper

  def test_LAZY_WORDS
    assert_equal(fixtures['lazy_words'], Spoonerise::LAZY_WORDS)
  end
end
