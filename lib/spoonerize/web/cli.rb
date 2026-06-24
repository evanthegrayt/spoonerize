# frozen_string_literal: true

require "optparse"

require_relative "../web"

module Spoonerize
  class Web
    ##
    # Command-line launcher for the web app.
    class Cli
      ##
      # Server options used when no command-line overrides are passed.
      #
      # @return [Hash]
      DEFAULT_OPTIONS = {
        host: Web.bind,
        port: Web.port
      }.freeze

      ##
      # Starts the web app from command-line arguments.
      #
      # @param [Array] options
      #
      # @return [nil]
      def self.execute(options = [])
        new(options).execute
      end

      ##
      # Parsed server options.
      #
      # @return [Hash]
      attr_reader :options

      ##
      # Create a web CLI launcher.
      #
      # @param [Array] options Command-line arguments.
      #
      # @return [self]
      def initialize(options)
        @options = DEFAULT_OPTIONS.merge(parse(options))
      end

      ##
      # Starts the Sinatra web app.
      #
      # @return [nil]
      def execute
        Web.run!(bind: options[:host], port: options[:port])
      end

      private

      def parse(options)
        {}.tap do |prefs|
          OptionParser.new do |o|
            o.version = ::Spoonerize::Version.to_s
            o.on("--host=HOST", "Host to bind") do |value|
              prefs[:host] = value
            end
            o.on("--port=PORT", Integer, "Port to bind") do |value|
              prefs[:port] = value
            end
          end.parse!(options)
        end
      end
    end
  end
end
