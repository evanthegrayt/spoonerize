require 'optparse'
require 'yaml'

module Spoonerise
  class Cli
    PREFERENCE_FILE =
      File.expand_path(File.join(ENV['HOME'], '.spoonerise.yml')).freeze

    ##
    # Creates an instance of +StandupMD+ and runs what the user requested.
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

    def initialize(options)
      @map         = false
      @save        = false
      @print       = false
      @options     = options
      @preferences = get_preferences
    end

    ##
    # Sets up an instance of +Spoonerise::Spoonerism+ and passes all user
    # preferences.
    #
    # @return [Spoonerise::Spoonerism]
    def spoonerism
      @spoonerism ||= ::Spoonerise::Spoonerism.new(options) do |s|
        preferences.each { |k, v| s.send("#{k}=", v) }
      end
    end

    def save?
      @save
    end

    def map?
      @map
    end

    def print?
      @print
    end

    def print_log
      s = Spoonerise::Log.new(spoonerism.logfile_name)
      s.each { |row| print row.join(' | ') + "\n" }
    end

    def longest_word_length
      @longest_word_length ||=
        spoonerism.spoonerise.group_by(&:size).max.first.size
    end

    def print_mappings
      spoonerism.to_h.each do |k, v|
        puts "%-#{longest_word_length}s => %s" % [k, v]
      end
    end

    private

    ##
    # Read in args and set options
    def get_preferences
      prefs = {}
      OptionParser.new do |o|
        o.version = ::Spoonerise::VERSION
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
      end.parse!(ARGV)

      (File.file?(PREFERENCE_FILE) ? YAML.load_file(PREFERENCE_FILE) : {})
        .merge(prefs)
    end

  end
end
