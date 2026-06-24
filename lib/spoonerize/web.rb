# frozen_string_literal: true

require "sinatra/base"

require_relative "../spoonerize"

module Spoonerize
  ##
  # Sinatra app for spoonerizing phrases in the browser.
  class Web < Sinatra::Base
    ##
    # Boolean Spoonerism options exposed by the web form.
    #
    # @return [Array<String>]
    OPTION_NAMES = %w[reverse lazy consonants_only].freeze

    set :root, File.expand_path(File.join(__dir__, "..", ".."))
    set :public_folder, File.expand_path(File.join(__dir__, "web", "public"))
    set :views, File.expand_path(File.join(__dir__, "web", "views"))
    set :static, true
    set :show_exceptions, false

    configure do
      Spoonerize.load_config_file(Spoonerize::CONFIG_FILE) if File.file?(Spoonerize::CONFIG_FILE)
    end

    helpers do
      ##
      # HTML checkbox attribute for a truthy option value.
      #
      # @param [String] name The option name.
      #
      # @return [String, nil]
      def checked?(name)
        option_value(name) ? "checked" : nil
      end

      ##
      # Current boolean value for a web form option.
      #
      # @param [String] name The option name.
      #
      # @return [Boolean]
      def option_value(name)
        @options.fetch(name.to_sym)
      end

      ##
      # Escapes a value for safe HTML output.
      #
      # @param [Object] value The value to escape.
      #
      # @return [String]
      def h(value)
        Rack::Utils.escape_html(value)
      end

      ##
      # Path for loading a saved spoonerism on the main web form.
      #
      # @param [String] phrase The original phrase.
      # @param [String] result The saved spoonerized result.
      #
      # @return [String]
      def saved_entry_path(phrase, result)
        "/?#{Rack::Utils.build_query("phrase" => phrase, "result" => result)}"
      end
    end

    get "/" do
      prepare_request(false)
      @result = params["result"].to_s unless params["result"].to_s.empty?
      erb :index
    end

    get "/saved" do
      redirect "/saved/"
    end

    get "/saved/" do
      @entries = saved_entries
      erb :saved
    end

    post "/" do
      prepare_request(true)
      @result = spoonerize_phrase if @submitted && !@phrase.strip.empty?

      erb :index
    end

    private

    def options_from_params
      OPTION_NAMES.to_h do |name|
        value = @submitted ? params.key?(name) : Spoonerize.config.public_send(name)
        [name.to_sym, value]
      end
    end

    def excluded_words_from(value)
      value.split(/[,\s]+/).reject(&:empty?)
    end

    def excluded_words_from_params
      return excluded_words_from(params["excluded_words"].to_s) if @submitted

      Spoonerize.config.excluded_words
    end

    def prepare_request(submitted)
      @submitted = submitted
      @phrase = params["phrase"].to_s
      @options = options_from_params
      @excluded_words = excluded_words_from_params
      @excluded_words_value = @excluded_words.join(" ")
      @save = @submitted && params.key?("save")
    end

    def saved_entries
      Spoonerize::Log.new(Spoonerize.config.logfile_name).contents.reverse
    end

    def spoonerize_phrase
      spoonerism = Spoonerism.new(
        *@phrase.split,
        **@options,
        excluded_words: @excluded_words
      )
      result = spoonerism.to_s
      spoonerism.save if @save
      @saved = @save

      result
    rescue => error
      @error = friendly_error(error)
      nil
    end

    def friendly_error(error)
      return "Not enough words to flip." if error.message == "Not enough words to flip"

      error.message
    end
  end
end
