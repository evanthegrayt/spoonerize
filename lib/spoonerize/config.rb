# frozen_string_literal: true

module Spoonerize
  class Config
    attr_accessor :excluded_words
    attr_accessor :lazy_words
    attr_accessor :lazy
    attr_accessor :reverse
    attr_accessor :logfile_name

    def initialize
      @excluded_words = []
      @lazy_words = %w[i a an and in of the my your his her him hers to is]
      @lazy = false
      @reverse = false
      @logfile_name =
        File.join(ENV["HOME"], ".cache", "spoonerize", "spoonerize.csv")
    end
  end
end
