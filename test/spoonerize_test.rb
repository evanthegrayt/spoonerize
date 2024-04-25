require_relative "../lib/spoonerize"
require_relative "test_helper"

##
# The test suite for +Spoonerize+.
class TestSpoonerize < Test::Unit::TestCase
  include TestHelper

  def test_LAZY_WORDS
    assert_equal(fixtures["lazy_words"], Spoonerize::LAZY_WORDS)
  end

  ##
  # +Spoonerize::Version+ should consist of three integers separated by dots.
  def test_version
    assert_match(/\d+\.\d+.\d+/, ::Spoonerize::Version.to_s)
  end
end
