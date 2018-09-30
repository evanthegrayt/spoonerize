#==============================================================#
#        File: pakjib.rb                                       #
# Description: The main word-flipper                           #
#                                                              #
#      Author: Evan Gray                                       #
#==============================================================#

require 'yaml'
require 'logger'
require 'optparse'

class PakJib

  JakPibError = Class.new(StandardError)

  LAZY_WORDS = YAML::load_file(
    File.join(File.dirname(__FILE__), 'config', 'lazy_words.yml')
  ).freeze

  attr_reader :words

  def initialize(words, opts = {})
    @words = words.map(&:downcase)
    @opts  = opts
    @opts[:exclude] ||= []

    raise JakPibError, "Not enough words to flip" unless enough_flippable_words?
  end

  def pakjib
    @pakjib ||= words.map.with_index do |word, idx|
      word = flip_words(word, idx)
    end.join(' ')
  end

  def save
    logger.info(pakjib)
  end

  def logfile
    @logfile ||= File.expand_path(
      File.join(File.dirname(__FILE__), '..', 'log', 'pakjib.log')
    )
  end

  private

  def flip_words(word, idx)
    bumper = set_bumper(idx)
    return word if excluded?(idx)
    bumper = bump(bumper) until !excluded?(bumper)
    words[bumper].match(consonants).to_s + word.match(vowels).to_s
  end

  def set_bumper(idx)
    bumper = @opts[:reverse] ? idx - 1 : idx + 1
    idx + 1 == words.size && !@opts[:reverse] ? 0 : bumper
  end

  def bump(bumper)
    bumper = @opts[:reverse] ? bumper - 1 : bumper + 1
    bumper == words.size ? 0 : bumper
  end

  def excluded?(index)
    excluded_words.include?(words[index])
  end

  def enough_flippable_words?
    (words - excluded_words).size > 1
  end

  def vowels
    /((?<!q)u|[aeio]|(?<=[bcdfghjklmnprstvwxz])y).*$/
  end

  def consonants
    /^(y|[bcdfghjklmnprstvwxz]+|qu)/
  end

  def flipped_words
    @flipped_words ||= []
  end

  def excluded_words
    @excluded_words ||= (
      %w(a i) + @opts[:exclude] + (@opts[:lazy] ? LAZY_WORDS : [])
    ).map(&:downcase)
  end

  def logger
    @logger ||= Logger.new(logfile, 0, 1048576)
  end

end

