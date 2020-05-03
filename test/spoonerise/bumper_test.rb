require_relative '../../lib/spoonerise'
require_relative '../test_helper'

##
# The test suite for +Cli+.
class TestBumper < Test::Unit::TestCase
  include TestHelper

  def test_initialize
    assert_nothing_raised { Spoonerise::Bumper.new(2, 5) }
    assert_nothing_raised { Spoonerise::Bumper.new(2, 5, true) }
  end

  def test_value
    b = Spoonerise::Bumper.new(2, 5)
    assert_equal(3, b.value)

    b = Spoonerise::Bumper.new(2, 5, true)
    assert_equal(1, b.value)
  end

  def test_bump
    b = Spoonerise::Bumper.new(3, 5)
    assert_equal(4, b.value)
    assert_equal(0, b.bump)

    b = Spoonerise::Bumper.new(1, 5, true)
    assert_equal(0, b.value)
    assert_equal(-1, b.bump)
  end

  def test_reverse?
    b = Spoonerise::Bumper.new(2, 5)
    refute(b.reverse?)

    b = Spoonerise::Bumper.new(2, 5, true)
    assert(b.reverse?)
  end
end
