module Spoonerise
  ##
  # Class that handles bumping an index.
  class Bumper

    attr_reader :value

    ##
    # Sets the bumper relative to the current index of words array.
    # If on the last element of the words array, sets the bumper to 0
    def initialize(initial_value, max_length, reverse = false)
      @max_length = max_length
      @reverse = reverse
      @value = set_value(initial_value)
    end

    ##
    # Bumps current value
    def bump
      @value = set_value(@value)
    end

    ##
    # Should we decrement instead of increment?
    def reverse?
      @reverse
    end

    private

    ##
    # {In,De}crements the bumper. If on the last element of the words array,
    # sets the bumper to 0.  We don't need to worry about resetting the value
    # to 0 when going in reverse, because when the array index is negative, it
    # reads from the end of the array, which is already what we want.
    def set_value(val)
      return val - 1 if @reverse
      val + 1 == @max_length ? 0 : val + 1
    end
  end
end
