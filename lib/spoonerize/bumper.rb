# frozen_string_literal: true

module Spoonerize
  ##
  # Class that handles bumping an index.
  class Bumper
    ##
    # The number after being bumped.
    #
    # @return [Integer]
    attr_reader :value

    ##
    # The maximum before index wraps back to zero.
    #
    # @return [Integer]
    attr_reader :max_value

    ##
    # Sets the bumper relative to the current index of words array. The value
    # is automatically bumped once when instantiated. If on the last element
    # of the words array, sets the bumper to 0.
    #
    # @param [Integer] initial_value
    #
    # @param [Integer] max_value
    #
    # @param [Boolean] reverse Flip the order
    def initialize(initial_value, max_value, reverse = false)
      @max_value = max_value
      @reverse = reverse
      @value = bump_value(initial_value)
    end

    ##
    # Increments/Decrements the bumper. If on the last element of the words
    # array, sets the bumper to 0. We don't need to worry about resetting the
    # value to 0 when going in reverse, because when the array index is
    # negative, it reads from the end of the array, which is already what we
    # want.
    #
    # @return [Integer]
    def bump
      @value = bump_value(value)
    end

    ##
    # Should we decrement instead of increment?
    #
    # @return [Boolean]
    def reverse?
      @reverse
    end

    private

    def bump_value(val) # :nodoc:
      return val - 1 if @reverse
      (val + 1 == @max_value) ? 0 : val + 1
    end
  end
end
