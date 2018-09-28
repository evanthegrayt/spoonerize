require 'logger'
require 'optparse'

class PakJib

  JakPibError = Class.new(StandardError)

  LAZY_WORDS = %w(an and in of the my your his her).freeze

  attr_reader :words

  def initialize(words, opts = {})
    @words = words.map { |i| i.downcase }
    @opts  = opts
    @opts[:exclude] ||= []

    raise JakPibError, "Not enough words to flip" unless enough_flippable_words?
  end

  def pakjib
    words.each_with_index { |word, idx| flipped_words << flip_words(word, idx) }
  end

  def results
    flipped_words.join(' ')
  end

  def save
    logger.info(results)
  end

  private

  def flip_words(word, idx)
    bumper = set_bumper(idx)
    return word if excluded?(idx)
    bumper = bump(bumper) until !excluded?(bumper)
    words[bumper].match(consonants).to_s + word.match(vowels).to_s
  end

  def excluded?(index)
    excluded_words.include?(words[index])
  end

  def set_bumper(idx)
    bumper = @opts[:reverse] ? idx - 1 : idx + 1
    idx + 1 == words.size && !@opts[:reverse] ? 0 : bumper
  end

  def bump(bumper)
    bumper = @opts[:reverse] ? bumper - 1 : bumper + 1
    bumper == words.size ? 0 : bumper
  end

  def enough_flippable_words?
    (words - excluded_words).size > 1
  end

  def vowels
    /((?<!q)u|[aeioy]).*$/
  end

  def consonants
    /^([bcdfghjklmnprstvwxyz]+|qu)(?<!y)/
  end

  def flipped_words
    @flipped_words ||= []
  end

  def excluded_words
    @excluded_words ||=
      %w(a i) + @opts[:exclude] + (@opts[:lazy] ? LAZY_WORDS : [])
  end

  def logger
    @logger ||=
      Logger.new(File.join(__dir__, '..', 'log', 'pakjib.log'), 0, 1048576)
  end

end

