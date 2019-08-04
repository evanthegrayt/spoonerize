#===============================================================#
#  File::        flipper.rb                                     #
#  Description:: The main word-flipper                          #
#                                                               #
#  Author::      Evan Gray                                      #
#===============================================================#
require 'forwardable'

module Spoonerise
class Flipper

  extend Forwardable

  attr_reader :words
  def_delegators :@logfile, :read, :write, :logfile

  ##
  # Initialize instance and raise if there aren't enough words to flip.
  def initialize(words, opts = {})
    @logfile = LogFile.new
    @words = words.map(&:downcase)
    @opts  = opts
    @opts[:exclude] ||= []

    raise JakPibError, 'Not enough words to flip' unless enough_flippable_words?
  end

  ##
  # Iterates through words array, and maps its elements to the output of
  # flip_words. Returns results as an array.
  def spoonerise
    @spoonerise ||= words.map.with_index { |word, idx| flip_words(word, idx) }
  end

  ##
  # Returns spoonerise array as a joined string.
  def to_s
    @to_s ||= spoonerise.join(' ')
  end

  ##
  # Returns hash of the original words mapped to their flipped counterparts.
  def to_h
    @to_h ||= Hash[words.zip(spoonerise)]
  end

  ##
  # Saves the flipped words to the log file, along with the runtime options.
  def save
    o = []
    o << 'Lazy'         if @opts[:lazy]
    o << 'Reverse'      if @opts[:reverse]
    o << 'Excluded(%s)' % [@opts[:exclude].join(' ')] if @opts[:exclude].any?
    o << 'No Options'   if o.empty?

    write(words.join(' '), to_s, o.join('|'))
  end

  private

  ##
  # Main flipping method. Creates the replacement word from the next
  # non-excluded word's leading syllables, and the current word's first vowels
  # through the end of the word.
  def flip_words(word, idx)
    return word if excluded?(idx)
    bumper = Bumper.new(idx, words.size, @opts[:reverse])
    bumper.bump until !excluded?(bumper.value)
    words[bumper.value].match(consonants).to_s + word.match(vowels).to_s
  end

  ##
  # Returns true if word[index] is in the excluded_words array
  def excluded?(index)
    excluded_words.include?(words[index])
  end

  ##
  # Returns true if there are more than one non-excluded word to flip
  def enough_flippable_words?
    (words - excluded_words).size > 1
  end

  ##
  # Returns regex to match first vowels through the rest of the word
  def vowels
    /((?<!q)u|[aeio]|(?<=[bcdfghjklmnprstvwxz])y).*$/
  end

  ##
  # Returns regex to match leading consonants
  def consonants
    /^(y|[bcdfghjklmnprstvwxz]+|qu)/
  end

  ##
  # Returns an array of words to exclude by combining three arrays:
  # * Any word in the passed arguments that's only one character
  # * Any user-passed words, stored in @opts[:exclude]
  # * If lazy-mode, the LAZY_WORDS from yaml file are added
  def excluded_words
    @excluded_words ||= (
       @opts[:exclude] +
       (@opts[:lazy] ? LAZY_WORDS : [])
    ).map(&:downcase)
  end

end
end

