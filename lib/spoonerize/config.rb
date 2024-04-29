# frozen_string_literal: true

module Spoonerize
  class Config
    ##
    # Lazy mode. If true, words in +lazy_words+ will not be altered.
    #
    # @return [Boolean]
    attr_accessor :lazy

    ##
    # Words to skip when +lazy+ is true.
    #
    # @return [Array]
    attr_accessor :lazy_words

    ##
    # Words that should not be altered.
    #
    # @return [Array]
    attr_accessor :excluded_words

    ##
    # When true, reverse the order of the flipping. Only makes a difference
    # when there are more than two flip-able words.
    #
    # @return [Boolean]
    attr_accessor :reverse

    ##
    # Name of the log file. Should be a fully-qualified file path.
    #
    # @return [String]
    attr_accessor :logfile_name

    ##
    # Create instance of Config.
    #
    # @return [Spoonerize::Config]
    def initialize
      @lazy = false
      @lazy_words = %w[i a an and in of the my your his her him hers to is]
      @excluded_words = []
      @reverse = false
      @logfile_name = File.expand_path(
        File.join(ENV["HOME"], ".cache", "spoonerize", "spoonerize.csv")
      )
    end
  end
end
