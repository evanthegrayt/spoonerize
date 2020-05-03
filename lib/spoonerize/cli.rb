require 'optparse'
require 'yaml'

module Spoonerize
  ##
  # The class for handling the command-line interface.
  class Cli

    ##
    # The preferences file the user can create to change runtime options.
    #
    # @return [String]
    PREFERENCE_FILE =
      File.expand_path(File.join(ENV['HOME'], '.spoonerize.yml')).freeze

    ##
    # Creates an instance of +StandupMD+ and runs what the user requested.
    #
    # @param [Array] options
    def self.execute(options = [])
      exe = new(options)

      if exe.print?
        exe.print_log
        return
      end

      puts exe.spoonerism.to_s
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
      @map         = false
      @save        = false
      @print       = false
      @options     = options
      @preferences = get_preferences
    end

    ##
    # Sets up an instance of +Spoonerize::Spoonerism+ and passes all user
    # preferences.
    #
    # @return [Spoonerize::Spoonerism]
    def spoonerism
      @spoonerism ||= ::Spoonerize::Spoonerism.new(options) do |s|
        preferences.each { |k, v| s.send("#{k}=", v) }
      end
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
    def print?
      @print
    end

    ##
    # The length of the longest word in the phrase.
    #
    # @return [Integer]
    def longest_word_length
      @longest_word_length ||=
        spoonerism.spoonerize.group_by(&:size).max.first.size
    end

    ##
    # Print the log file contents to the command line.
    #
    # @return [nil]
    def print_log
      s = Spoonerize::Log.new(spoonerism.logfile_name)
      s.each { |row| print row.join(' | ') + "\n" }
    end

    ##
    # Print the hash of mappings to the command line.
    #
    # @return [nil]
    def print_mappings
      spoonerism.to_h.each do |k, v|
        puts "%-#{longest_word_length}s => %s" % [k, v]
      end
    end

    private

    ##
    # Read in args and set options
    def get_preferences # :nodoc:
      prefs = {}
      OptionParser.new do |o|
        o.version = ::Spoonerize::VERSION
        o.on('-r', '--[no-]reverse', 'Reverse flipping') do |v|
          prefs['reverse'] = v
        end
        o.on('-l', '--[no-]lazy', 'Skip small words') do |v|
          prefs['lazy'] = v
        end
        o.on('-m', '--[no-]map', 'Print words mapping') do |v|
          @map = v
        end
        o.on('-p', '--[no-]print', 'Print all entries in the log') do |v|
          @print = v
        end
        o.on('-s', '--[no-]save', 'Save results in log') do |v|
          @save = v
        end
        o.on('--exclude=WORDS', Array, 'Words to skip') do |v|
          prefs['exclude'] = v
        end
      end.parse!(options)

      (File.file?(PREFERENCE_FILE) ? YAML.load_file(PREFERENCE_FILE) : {})
        .merge(prefs)
    end
  end
end
