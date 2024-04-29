# frozen_string_literal: true

module Spoonerize
  ##
  # The main word-flipper.
  class Spoonerism
    ##
    # The words originally passed at initialization.
    #
    # @return [Array]
    attr_reader :words

    ##
    # The words that are to be excluded.
    #
    # @param [Array] words
    #
    # @return [Array]
    attr_accessor :excluded_words

    ##
    # Initialize instance.
    #
    # @param [Array] words
    #
    # @return [Spoonerize::Spoonerism]
    def initialize(words)
      @words = words.map(&:downcase)
    end

    ##
    # Iterates through words array, and maps its elements to the output of
    # flip_words.
    #
    # @return [Array]
    def spoonerize
      raise "Not enough words to flip" unless enough_flippable_words?

      words.map.with_index { |word, idx| flip_words(word, idx) }
    end

    ##
    # Spoonerized results as a joined string.
    #
    # @return [String]
    def to_s
      spoonerize.join(" ")
    end

    ##
    # Spoonerized results as a joined hash.
    #
    # @return [Hash]
    def to_h
      words.zip(spoonerize).to_h
    end

    ##
    # Same as to_h, but as json.
    #
    # @return [String]
    def to_json
      to_h.to_json
    end

    ##
    # True if there are more than one non-excluded word to flip
    #
    # @return [Boolean]
    def enough_flippable_words?
      (words - all_excluded_words).size > 1
    end

    ##
    # Saves the flipped words to the log file, along with the options
    #
    # @return [Array]
    def save
      log.write([words.join(" "), to_s, options.join(", ")])
    end

    ##
    # Array of words to exclude by combining two arrays:
    # * Any user-passed words, stored in +excluded_words+
    # * Any lazy words, if lazy mode is true
    #
    # @return [Array]
    def all_excluded_words
      (Spoonerize.config.excluded_words + (
        Spoonerize.config.lazy ? Spoonerize.config.lazy_words : []
      )).map(&:downcase)
    end

    private

    ##
    # Main flipping method. Creates the replacement word from the next
    # non-excluded word's leading syllables, and the current word's first vowels
    # through the end of the word.
    def flip_words(word, idx) # :nodoc:
      return word if excluded?(idx)
      bumper = Bumper.new(idx, words.size, Spoonerize.config.reverse)
      bumper.bump while excluded?(bumper.value)
      words[bumper.value].match(consonants).to_s + word.match(vowels).to_s
    end

    ##
    # Returns true if word[index] is in the excluded_words array
    def excluded?(index) # :nodoc:
      all_excluded_words.include?(words[index])
    end

    ##
    # Returns regex to match first vowels through the rest of the word
    def vowels # :nodoc:
      /((?<!q)u|[aeio]|(?<=[bcdfghjklmnprstvwxz])y).*$/
    end

    ##
    # Returns regex to match leading consonants
    def consonants # :nodoc:
      /^(y|[bcdfghjklmnprstvwxz]+|qu)/
    end

    ##
    # Creates and memoizes instance of the log file.
    def log # :nodoc:
      @log ||= Spoonerize::Log.new(Spoonerize.config.logfile_name)
    end

    ##
    # The options that were passed at runtime as a string
    def options # :nodoc:
      [].tap do |o|
        o << "Lazy" if Spoonerize.config.lazy
        o << "Reverse" if Spoonerize.config.reverse
        if Spoonerize.config.excluded_words.any?
          o << "Exclude [#{Spoonerize.config.excluded_words.join(", ")}]"
        end
        o << "No Options" if o.empty?
      end
    end
  end
end
