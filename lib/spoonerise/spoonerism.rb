module Spoonerise
##
# The main word-flipper.
class Spoonerism

  attr_reader :words

  attr_writer :lazy, :reverse

  attr_accessor :logfile_name, :excluded_words

  ##
  # Initialize instance and raise if there aren't enough words to flip.
  #
  # @param [Array] words
  def initialize(words)
    @excluded_words = []
    @words = words.map(&:downcase)
    @lazy = false
    @reverse = false
    @logfile_name = File.expand_path(
      File.join(ENV['HOME'], '.cache', 'spoonerise', 'spoonerise.csv')
    )
    yield self if block_given?
  end

  ##
  # Iterates through words array, and maps its elements to the output of
  # flip_words. Returns results as an array.
  def spoonerise
    raise JakPibError, 'Not enough words to flip' unless enough_flippable_words?
    words.map.with_index { |word, idx| flip_words(word, idx) }
  end

  ##
  # Returns spoonerise array as a joined string.
  def to_s
    spoonerise.join(' ')
  end

  ##
  # Returns hash of the original words mapped to their flipped counterparts.
  def to_h
    Hash[words.zip(spoonerise)]
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
    @log ||= Spoonerise::Log.new(logfile_name)
  end

  ##
  # the options as a string
  def options # :nodoc:
    o = []
    o << 'Lazy' if lazy?
    o << 'Reverse' if reverse?
    o << 'Exclude [%s]' % [all_excluded_words.join(', ')] if excluded_words.any?
    o << 'No Options' if o.empty?
    o
  end
end
end
