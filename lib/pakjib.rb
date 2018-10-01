#===============================================================#
#  File::        pakjib.rb                                      #
#  Description:: The main word-flipper                          #
#                                                               #
#  Author::      Evan Gray                                      #
#===============================================================#

require 'yaml'
require 'logger'
require 'optparse'

class PakJib

  JakPibError = Class.new(StandardError)

  # Load in excluded words from yaml file as frozen constant
  LAZY_WORDS = YAML::load_file(
    File.join(File.dirname(__FILE__), 'config', 'lazy_words.yml')
  ).freeze

  attr_reader :words

  # Initialize instance of pakjib and raise if there aren't enough words to flip
  def initialize(words, opts = {})
    @words = words.map(&:downcase)
    @opts  = opts
    @opts[:exclude] ||= []

    raise JakPibError, "Not enough words to flip" unless enough_flippable_words?
  end

  # Method: pakjib
  # Iterates through words array, and maps its elements to the output of
  # flip_words. Returns results as an array.
  def pakjib
    @pakjib ||= words.map.with_index { |word, i| word = flip_words(word, i) }
  end

  # Method: to_s
  # Returns pakjib array as a joined string
  def to_s
    @to_s ||= pakjib.join(' ')
  end

  # Method: save
  # Saves the flipped words to the log file
  def save
    logger.info(to_s)
  end

  # Method: logfile
  # Creates and memoizes the path to the log file
  def logfile
    @logfile ||= File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'log', 'pakjib.log')
    )
  end

  private

  # Method: flip_words
  # Main flipping method. Creates the replacement word from the next
  # non-excluded word's leading syllables, and the current word's first vowels
  # through the end of the word.
  def flip_words(word, idx)
    bumper = set_bumper(idx)
    return word if excluded?(idx)
    bumper = bump(bumper) until !excluded?(bumper)
    words[bumper].match(consonants).to_s + word.match(vowels).to_s
  end

  # Method: set_bumper
  # Sets the bumper relative to the current index of words array.
  # If on the last element of the words array, sets the bumper to 0
  def set_bumper(idx)
    bumper = @opts[:reverse] ? idx - 1 : idx + 1
    idx + 1 == words.size && !@opts[:reverse] ? 0 : bumper
  end

  # Method: bump
  # {In,De}crements the bumper.
  # If on the last element of the words array, sets the bumper to 0
  def bump(bumper)
    bumper = @opts[:reverse] ? bumper - 1 : bumper + 1
    bumper == words.size ? 0 : bumper
  end

  # Method: excluded?
  # Returns true if word[index] is in the excluded_words array
  def excluded?(index)
    excluded_words.include?(words[index])
  end

  # Method: enough_flippable_words?
  # Returns true if there are more than one non-excluded word to flip
  def enough_flippable_words?
    (words - excluded_words).size > 1
  end

  # Method: vowels
  # Returns regex to match first vowels through the rest of the word
  def vowels
    /((?<!q)u|[aeio]|(?<=[bcdfghjklmnprstvwxz])y).*$/
  end

  # Method: consonants
  # Returns regex to match leading consonants
  def consonants
    /^(y|[bcdfghjklmnprstvwxz]+|qu)/
  end

  # Method: excluded_words
  # Returns an array of words to exclude by combining three arrays:
  # * Any word in the passed arguments that's only one character
  # * Any user-passed words, stored in @opts[:exclude]
  # * If lazy-mode, the LAZY_WORDS from yaml file are added
  def excluded_words
    @excluded_words ||= (
       (words.select { |w| w.length == 1 }) +
       @opts[:exclude] +
       (@opts[:lazy] ? LAZY_WORDS : [])
    ).map(&:downcase)
  end

  # Method: logger
  # Creates and memoizes instance of Logger
  def logger
    @logger ||= Logger.new(logfile, 0, 1048576)
  end

end

