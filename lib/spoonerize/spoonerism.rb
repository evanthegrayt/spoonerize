# frozen_string_literal: true

module Spoonerize
  ##
  # The main word-flipper.
  class Spoonerism
    VOWEL_LETTERS = "aeio"
    CONSONANT_LETTERS = "bcdfghjklmnprstvwxz"
    Y_FOLLOWING_CONSONANTS = "bcdfghjklmnpqrstvwxz"

    ##
    # The words originally passed at initialization.
    #
    # @return [Array]
    attr_reader :words

    ##
    # Configuration values for this spoonerism.
    #
    # @return [Spoonerize::Config]
    attr_reader :config

    ##
    # Initialize instance.
    #
    # @param [Array<String>] words Words to spoonerize. Passing a single array
    #   is deprecated and will be removed in Spoonerize 1.0.
    # @param [Spoonerize::Config] config Base config to copy.
    # @param [Boolean, nil] lazy Override lazy mode for this instance.
    # @param [Array<String>, nil] lazy_words Override lazy words for this instance.
    # @param [Array<String>, nil] excluded_words Override excluded words for this instance.
    # @param [Boolean, nil] reverse Override reverse mode for this instance.
    # @param [String, nil] logfile_name Override the log file path for this instance.
    #
    # @return [Spoonerize::Spoonerism]
    def initialize(
      *words,
      config: Spoonerize.config,
      lazy: nil,
      lazy_words: nil,
      excluded_words: nil,
      reverse: nil,
      logfile_name: nil
    )
      @words = normalize_words(words).map(&:downcase)
      @config = config.with(**{
        lazy: lazy,
        lazy_words: lazy_words,
        excluded_words: excluded_words,
        reverse: reverse,
        logfile_name: logfile_name
      }.reject { |_, value| value.nil? })
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
    # * Any user-passed words, stored in +config.excluded_words+
    # * Any lazy words, if lazy mode is true
    #
    # @return [Array]
    def all_excluded_words
      (config.excluded_words + (
        config.lazy ? config.lazy_words : []
      )).map(&:downcase)
    end

    private

    def normalize_words(words)
      if words.size == 1 && words.first.is_a?(Array)
        warn(
          "Passing words as an array is deprecated and will be removed in Spoonerize 1.0. " \
          "Pass words as positional arguments instead."
        )
        words = words.first
      end

      unless words.all? { |word| word.is_a?(String) }
        raise ArgumentError, "Words must be strings"
      end

      words
    end

    ##
    # Main flipping method. Creates the replacement word from the next
    # non-excluded word's leading consonants, and the current word's first
    # vowel sound through the end of the word.
    def flip_words(word, idx) # :nodoc:
      return word if excluded?(idx)
      bumper = Bumper.new(idx, words.size, config.reverse)
      bumper.bump while excluded?(bumper.value)
      leading_consonants(words[bumper.value]) + retained_suffix(word)
    end

    ##
    # Returns true if word[index] is in the excluded_words array
    def excluded?(index) # :nodoc:
      all_excluded_words.include?(words[index])
    end

    ##
    # Returns the consonant group a word contributes to another word.
    def leading_consonants(word) # :nodoc:
      return "qu" if word.start_with?("qu")
      return "y" if initial_y_consonant?(word)

      index = word.length.times.find do |letter_index|
        !CONSONANT_LETTERS.include?(word[letter_index])
      end

      index ? word[0...index] : word
    end

    ##
    # Returns the part of a word kept after dropping its leading consonants.
    def retained_suffix(word) # :nodoc:
      index = first_vowel_sound_index(word)

      index ? word[index..-1] : ""
    end

    ##
    # Returns the first index where a word starts sounding vowel-like.
    def first_vowel_sound_index(word) # :nodoc:
      word.length.times.find { |index| vowel_sound_at?(word, index) }
    end

    ##
    # Returns true when the letter at index starts a vowel sound.
    def vowel_sound_at?(word, index) # :nodoc:
      letter = word[index]

      VOWEL_LETTERS.include?(letter) ||
        (letter == "u" && word[index - 1] != "q") ||
        y_vowel_sound_at?(word, index)
    end

    ##
    # Initial y is vowel-like before a consonant; later y is vowel-like after a
    # consonant.
    def y_vowel_sound_at?(word, index) # :nodoc:
      return false unless word[index] == "y"

      if index.zero?
        next_letter = word[index + 1]

        next_letter && Y_FOLLOWING_CONSONANTS.include?(next_letter)
      else
        CONSONANT_LETTERS.include?(word[index - 1])
      end
    end

    ##
    # Initial y is consonant-like by itself or before a vowel sound.
    def initial_y_consonant?(word) # :nodoc:
      word == "y" || (word.start_with?("y") && vowel_sound_at?(word, 1))
    end

    ##
    # Creates and memoizes instance of the log file.
    def log # :nodoc:
      @log ||= Spoonerize::Log.new(config.logfile_name)
    end

    ##
    # The options that were passed at runtime as a string
    def options # :nodoc:
      [].tap do |o|
        o << "Lazy" if config.lazy
        o << "Reverse" if config.reverse
        if config.excluded_words.any?
          o << "Exclude [#{config.excluded_words.join(", ")}]"
        end
        o << "No Options" if o.empty?
      end
    end
  end
end
