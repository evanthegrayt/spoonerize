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

    assert_match(/class="notice">Not enough words to flip\.<\/p>/, body)
    refute(File.file?(test_log_file))
  end

  def test_errors_are_friendly
    body = post("/", phrase: "test")

    assert_match(/class="notice">Not enough words to flip\.<\/p>/, body)
    refute_match(/class="result"/, body)
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
