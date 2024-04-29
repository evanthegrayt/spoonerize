# frozen_string_literal: true

require "optparse"

module Spoonerize
  ##
  # The class for handling the command-line interface.
  class Cli
    ##
    # The config file the user can create to change default runtime options.
    #
    # @return [String]
    CONFIG_FILE = File.expand_path(File.join(ENV["HOME"], ".spoonerizerc"))

    ##
    # Creates an instance of +Spoonerism+ and runs what the user requested.
    #
    # @param [Array] options
    def self.execute(options = [])
      exe = new(options)

      if exe.print_log?
        exe.print_log
        return
      end

      puts exe.spoonerism
      exe.print_mappings if exe.map?

      if exe.save?
        puts "Saving..."
        exe.spoonerism.save
      end
    end

    ##
    # Arguments passed at runtime.
    #
    # @return [Array] ARGV
    attr_reader :options

    ##
    # Preferences after reading config file and parsing ARGV.
    #
    # @return [Array]
    attr_reader :preferences

    ##
    # Create instance of +Cli+
    #
    # @param [Array] options
    #
    # @return [self]
    def initialize(options)
      Spoonerize.load_config_file(CONFIG_FILE) if File.file?(CONFIG_FILE)
      @map = false
      @save = false
      @print_log = false
      @options = options
      @preferences = get_preferences
    end

    ##
    # Sets up an instance of +Spoonerize::Spoonerism+
    #
    # @return [Spoonerize::Spoonerism]
    def spoonerism
      @spoonerism ||= Spoonerism.new(options)
    end

    ##
    # Should we save to the log file?
    #
    # @return [Boolean]
    def save?
      @save
    end

    ##
    # Should we print the mappings to the command line?
    #
    # @return [Boolean]
    def map?
      @map
    end

    ##
    # Should we print to the command line?
    #
    # @return [Boolean]
    def print_log?
      @print_log
    end

    ##
    # The length of the longest word in the phrase.
    #
    # @return [Integer]
    def longest_word_length
      @longest_word_length ||= spoonerism.spoonerize.max_by(&:size).size
    end

    ##
    # Print the log file contents to the command line.
    #
    # @return [nil]
    def print_log
      Spoonerize::Log.new(Spoonerize.config.logfile_name).each do |row|
        puts row.join(" | ")
      end
    end

    ##
    # Print the hash of mappings to the command line.
    #
    # @return [nil]
    def print_mappings
      spoonerism.to_h.each do |k, v|
        printf("%-#{longest_word_length + 1}s => %s\n", k, v)
      end
    end

    private

    ##
    # Read in args and set options
    def get_preferences # :nodoc:
      {}.tap do |prefs|
        OptionParser.new do |o|
          o.version = ::Spoonerize::Version.to_s
          o.on("-r", "--[no-]reverse", "Reverse flipping") do |v|
            Spoonerize.config.reverse = v
          end
          o.on("-l", "--[no-]lazy", "Skip small words") do |v|
            Spoonerize.config.lazy = v
          end
          o.on("-m", "--[no-]map", "Print words mapping") do |v|
            @map = v
          end
          o.on("-p", "--[no-]print-log", "Print all entries in the log") do |v|
            @print_log = v
          end
          o.on("-s", "--[no-]save", "Save results in log") do |v|
            @save = v
          end
          o.on("--exclude=WORD", Array, "Words to skip") do |v|
            Spoonerize.config.exclude = v
          end
        end.parse!(options)
      end
    end
  end
end
