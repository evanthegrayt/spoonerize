require 'csv'
require 'fileutils'

module Spoonerise
  ##
  # Class that handles reading/writing logs.
  class Log

    ##
    # The file name to use.
    #
    # @return [String]
    attr_reader :file

    ##
    # The directory the file is located.
    #
    # @return [String]
    attr_reader :directory

    ##
    # Constructor for Log.
    #
    # @param [String] file
    #
    # @return [Spoonerise::Log]
    def initialize(file)
      @file = File.expand_path(file)
      @directory = File.dirname(file)
      FileUtils.mkdir_p(directory) unless File.directory?(directory)
      FileUtils.touch(file) unless File.file?(file)
    end

    ##
    # The contents of the log file.
    #
    # @return [Array]
    def contents
      ::CSV.read(file)
    end

    ##
    # Writes a line to the log.
    #
    # @param [Array] row
    #
    # @return [Array]
    def write(row)
      ::CSV.open(file, 'a') { |csv| csv << row }
    end

    ##
    # Iterate through each line of the file.
    #
    # @return [Array]
    def each
      contents.each { |row| yield row }
    end

    ##
    # Number of entries in the file.
    #
    # @return [Integer]
    def size
      contents.size
    end
  end
end
