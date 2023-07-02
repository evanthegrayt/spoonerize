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
    # Initialize instance. You can also use the +config_file+ either by passing
    # it at initialization, or via the setter. The config file will be
    # automatically loaded if passed at initialization, before the instance is
    # yielded so you can still change the values via the block. If set via the
    # setter, you must call `#load_config_file`.
    #
    # @param [Array] words
    #
    # @param [String] config_file
    #
    # @example
    #  # Config file would be automatically loaded before block is executed.
    #  s = Spoonerise::Spoonerism.new(%w[not too shabby], '~/.spoonerize.yml') do |sp|
    #    sp.reverse = true # Would override setting from config file
    #  end
    #  # Config file would need to be manually loaded.
    #  s = Spoonerise::Spoonerism.new(%w[not too shabby]) do |sp|
    #    sp.config_file = '~/.spoonerize.yml'
    #    sp.reverse = true
    #  end
    #  s.load_config_file # Would override setting from initialization
    def initialize(words, config_file = nil)
      @words = words.map(&:downcase)
      @config_file = config_file && File.expand_path(config_file)
      @config_file_loaded = false

      Spoonerize.load_config_file if config_file

      yield self if block_given?
    end

    ##
    # Iterates through words array, and maps its elements to the output of
    # flip_words. Returns results as an array.
    def spoonerize
      raise JakPibError, "Not enough words to flip" unless enough_flippable_words?

      words.map.with_index { |word, idx| flip_words(word, idx) }
    end

    ##
    # Returns spoonerize array as a joined string.
    def to_s
      spoonerize.join(" ")
    end

    ##
    # Returns hash of the original words mapped to their flipped counterparts.
    def to_h
      words.zip(spoonerize).to_h
    end

    ##
    # Same as to_h, but as json.
    def to_json
      to_h.to_json
    end

    ##
    # Returns true if there are more than one non-excluded word to flip
    def enough_flippable_words?
      (words - all_excluded_words).size > 1
    end

    ##
    # Saves the flipped words to the log file, along with the options
    def save
      log.write([words.join(" "), to_s, options.join(", ")])
    end

    ##
    # Returns an array of words to exclude by combining three arrays:
    # * Any word in the passed arguments that's only one character
    # * Any user-passed words, stored in +excluded_words+
    # * If lazy-mode, the LAZY_WORDS from yaml file are added
    def all_excluded_words
      (Spoonerize.config.excluded_words + (Spoonerize.config.lazy? ? Spoonerize.config.lazy_words : [])).map(&:downcase)
    end

    private

    ##
    # Main flipping method. Creates the replacement word from the next
    # non-excluded word's leading syllables, and the current word's first vowels
    # through the end of the word.
    def flip_words(word, idx) # :nodoc:
      return word if excluded?(idx)
      bumper = Bumper.new(idx, words.size, reverse?)
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
      @log ||= Spoonerize::Log.new(logfile_name)
    end

    ##
    # the options as a string
    def options # :nodoc:
      [].tap do |o|
        o << "Lazy" if Spoonerize.config.lazy?
        o << "Reverse" if Spoonerize.config.reverse?
        o << "Exclude [#{all_excluded_words.join(", ")}]" if Spoonerize.config.excluded_words.any?
        o << "No Options" if o.empty?
      end
    end
  end
end
