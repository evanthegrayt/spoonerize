require "rack/mock"

require_relative "../../lib/spoonerize/web"
require_relative "../test_helper"

class TestWeb < Test::Unit::TestCase
  include TestHelper

  def setup
    reset_spoonerize_config
  end

  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  def test_initial_render_is_blank
    body = get("/")

    assert_match(/<form action="\/" method="post"/, body)
    assert_match(%r{href="/saved/">Saved spoonerisms</a>}, body)
    assert_match(%r{href="https://github\.com/evanthegrayt">evanthegrayt</a>}, body)
    assert_match(%r{href="https://github\.com/evanthegrayt/spoonerize">spoonerize</a>}, body)
    assert_match(/placeholder="Enter phrase to spoonerize\.\.\."/m, body)
    assert_match(/name="phrase"\s+value=""/m, body)
    refute_match(/class="result"/, body)
    refute_match(/class="notice"/, body)
  end

  def test_initial_render_uses_config_defaults
    Spoonerize.config.reverse = true
    Spoonerize.config.lazy = true
    Spoonerize.config.consonants_only = true
    Spoonerize.config.excluded_words = %w[ultimate test]

    body = get("/")

    assert_match(/name="reverse" value="1" checked/m, body)
    assert_match(/name="lazy" value="1" checked/m, body)
    assert_match(/name="consonants_only" value="1" checked/m, body)
    assert_match(/name="excluded_words"\s+value="ultimate test"/m, body)
  end

  def test_submitted_unchecked_boxes_override_config_defaults
    Spoonerize.config.reverse = true
    Spoonerize.config.lazy = true
    Spoonerize.config.consonants_only = true

    body = post("/", phrase: "not too shabby")

    assert_match(/class="result">tot shoo nabby</, body)
    refute_match(/name="reverse" value="1" checked/m, body)
    refute_match(/name="lazy" value="1" checked/m, body)
    refute_match(/name="consonants_only" value="1" checked/m, body)
  end

  def test_submitted_phrase_is_split_and_preserved
    body = post("/", phrase: "not too shabby", reverse: "1")

    assert_match(/class="result">shot noo tabby</, body)
    assert_match(/name="phrase"\s+value="not too shabby"/m, body)
    assert_match(/name="reverse" value="1" checked/m, body)
  end

  def test_excluded_words_are_parsed_and_preserved
    body = post(
      "/",
      phrase: "the ultimate spoonerize test",
      excluded_words: "ultimate, test"
    )

    assert_match(/class="result">spe ultimate thoonerize test</, body)
    assert_match(/name="excluded_words"\s+value="ultimate test"/m, body)
  end

  def test_saved_entry_can_be_loaded_on_initial_render
    body = get("/", phrase: "big fun", result: "fig bun")

    assert_match(/class="result">fig bun</, body)
    assert_match(/name="phrase"\s+value="big fun"/m, body)
  end

  def test_save_writes_successful_result_to_log
    Spoonerize.config.logfile_name = test_log_file

    body = post("/", phrase: "not too shabby", reverse: "1", save: "1")

    assert_match(/class="result">shot noo tabby</, body)
    assert_match(/class="notice">Saved\.<\/p>/, body)
    assert_match(/name="save" value="1" checked/m, body)
    assert_equal([["not too shabby", "shot noo tabby", "Reverse"]], Spoonerize::Log.new(test_log_file).contents)
  end

  def test_save_does_not_write_failed_result
    Spoonerize.config.logfile_name = test_log_file

    body = post("/", phrase: "test", save: "1")

    assert_match(/class="notice">Not enough words to spoonerize\.<\/p>/, body)
    refute(File.file?(test_log_file))
  end

  def test_errors_are_friendly
    body = post("/", phrase: "test")

    assert_match(/class="notice">Not enough words to spoonerize\.<\/p>/, body)
    refute_match(/class="result"/, body)
  end

  def test_saved_render_lists_log_entries
    Spoonerize.config.logfile_name = test_log_file
    Spoonerize::Log.new(test_log_file).write(["not too shabby", "shot noo tabby", "Reverse"])
    Spoonerize::Log.new(test_log_file).write(["big fun", "fig bun", "No Options"])

    body = get("/saved/")

    assert_match(/<h1>Saved spoonerisms<\/h1>/, body)
    assert_match(/2 saved spoonerisms/, body)
    assert_match(%r{href="/">New spoonerism</a>}, body)
    assert_match(%r{href="/\?phrase=big\+fun&amp;result=fig\+bun">big fun</a>}, body)
    assert_match(%r{href="/\?phrase=big\+fun&amp;result=fig\+bun"><strong>fig bun</strong></a>}, body)
    assert_match(%r{href="/\?phrase=big\+fun&amp;result=fig\+bun">No Options</a>}, body)
    assert_match(%r{href="/\?phrase=not\+too\+shabby&amp;result=shot\+noo\+tabby">not too shabby</a>}, body)
    assert_match(%r{href="/\?phrase=not\+too\+shabby&amp;result=shot\+noo\+tabby"><strong>shot noo tabby</strong></a>}, body)
    assert_match(%r{href="/\?phrase=not\+too\+shabby&amp;result=shot\+noo\+tabby">Reverse</a>}, body)
  end

  def test_saved_render_escapes_log_entries
    Spoonerize.config.logfile_name = test_log_file
    Spoonerize::Log.new(test_log_file).write(["<b>bold</b> words", "<i>spoonerize</i> words", "No Options"])

    body = get("/saved/")

    assert_match(/&lt;b&gt;bold&lt;\/b&gt; words/, body)
    assert_match(/&lt;i&gt;spoonerize&lt;\/i&gt; words/, body)
    refute_match(/<b>bold<\/b>/, body)
    refute_match(/<i>spoonerize<\/i>/, body)
  end

  def test_saved_render_has_empty_state
    Spoonerize.config.logfile_name = test_log_file

    body = get("/saved/")

    assert_match(/0 saved spoonerisms/, body)
    assert_match(/class="notice">No saved spoonerisms yet\.<\/p>/, body)
    refute_match(/class="saved-table"/, body)
  end

  private

  def get(path, params = {})
    query = Rack::Utils.build_query(params)
    target = query.empty? ? path : "#{path}?#{query}"

    Rack::MockRequest.new(Spoonerize::Web).get(target).body
  end

  def post(path, params = {})
    Rack::MockRequest.new(Spoonerize::Web).post(path, params: params).body
  end
end
