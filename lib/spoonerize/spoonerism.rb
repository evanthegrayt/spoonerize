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
    # This boolean determines if flipping should be performed lazily.
    #
    # @param [Boolean] true if should be lazy.
    #
    # @return [Boolean]
    attr_writer :lazy

    ##
    # This boolean determines if flipping should be reversed.
    #
    # @param [Boolean] true if should be reversed.
    #
    # @return [Boolean]
    attr_writer :reverse

    ##
    # The full path to the log file.
    #
    # @param [String] file
    #
    # @return [String]
    attr_accessor :logfile_name

    ##
    # The words that are to be excluded.
    #
    # @param [Array] words
    #
    # @return [Array]
    attr_accessor :excluded_words

    ##
    # The configuration file. Default is +nil+. If set to a string, and the file
    # exists, it is used to set options.
    #
    # @return [String] file path
    attr_reader :config_file

    ##
    # The options from +config_file+ as a hash.
    #
    # @return [Hash] Options from +config_file+
    attr_reader :config

    ##
    # Initialize instance and raise if there aren't enough words to flip. Can
    # pass a config file to be loaded.
    #
    # @param [Array] words
    #
    # @param [String] config_file
    def initialize(words, config_file = nil)
      @config = {}
      @excluded_words = []
      @words = words.map(&:downcase)
      @lazy = false
      @reverse = false
      @config_file = config_file && File.expand_path(config_file)
      @config_file_loaded = false
      @logfile_name = File.expand_path(
        File.join(ENV['HOME'], '.cache', 'spoonerize', 'spoonerize.csv')
      )

      load_config_file if config_file

      yield self if block_given?
    end

    ##
    # Iterates through words array, and maps its elements to the output of
    # flip_words. Returns results as an array.
    def spoonerize
      raise JakPibError, 'Not enough words to flip' unless enough_flippable_words?
      words.map.with_index { |word, idx| flip_words(word, idx) }
    end

    ##
    # Returns spoonerize array as a joined string.
    def to_s
      spoonerize.join(' ')
    end

    ##
    # Returns hash of the original words mapped to their flipped counterparts.
    def to_h
      Hash[words.zip(spoonerize)]
    end

    ##
    # Same as to_h, but as json.
    def to_json
      to_h.to_json
    end

    ##
    # Has a config file been loaded?
    #
    # @return [Boolean]
    def config_file_loaded?
      @config_file_loaded
    end

    ##
    # Returns true if there are more than one non-excluded word to flip
    def enough_flippable_words?
      (words - all_excluded_words).size > 1
    end

    ##
    # Should the lazy words be excluded?
    def lazy?
      @lazy
    end

    ##
    # Should the words flip the other direction?
    def reverse?
      @reverse
    end

    ##
    # Saves the flipped words to the log file, along with the options
    def save
      log.write([words.join(' '), to_s, options.join(', ')])
    end

    ##
    # Returns an array of words to exclude by combining three arrays:
    # * Any word in the passed arguments that's only one character
    # * Any user-passed words, stored in +excluded_words+
    # * If lazy-mode, the LAZY_WORDS from yaml file are added
    def all_excluded_words
      (excluded_words + (lazy? ? LAZY_WORDS : [])).map(&:downcase)
    end

    ##
    # Setter for +config_file+. Must be expanded in case the user uses `~` for
    # home.
    #
    # @param [String] file
    #
    # @return [String]
    def config_file=(config_file)
      @config_file = File.expand_path(config_file)
    end

    ##
    # Loads the config file
    #
    # @return [Hash] The config options
    def load_config_file
      raise 'No config file set' if config_file.nil?
      raise "File #{config_file} does not exist" unless File.file?(config_file)
      @config = YAML::load_file(config_file)
      @config_file_loaded = true
      @config.each { |k, v| send("#{k}=", v) }
    end

    private

    ##
    # Main flipping method. Creates the replacement word from the next
    # non-excluded word's leading syllables, and the current word's first vowels
    # through the end of the word.
    def flip_words(word, idx) # :nodoc:
      return word if excluded?(idx)
      bumper = Bumper.new(idx, words.size, reverse?)
      bumper.bump until !excluded?(bumper.value)
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
      o = []
      o << 'Lazy' if lazy?
      o << 'Reverse' if reverse?
      o << "Exclude [#{all_excluded_words.join(', ')}]" if excluded_words.any?
      o << 'No Options' if o.empty?
      o
    end
  end
end
