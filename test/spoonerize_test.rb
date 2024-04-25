require_relative "../lib/spoonerize"
require_relative "test_helper"

##
# The test suite for +Spoonerize+.
class TestSpoonerize < Test::Unit::TestCase
  include TestHelper

  def setup
    Spoonerize.instance_variable_set("@config_file_loaded", false)
  end

  ##
  # +Spoonerize::Version+ should consist of three integers separated by dots.
  def test_version
    assert_match(/\d+\.\d+.\d+/, ::Spoonerize::Version.to_s)
    assert_match(/\d+\.\d+.\d+/, ::Spoonerize::VERSION)
  end

  def test_config
    assert_instance_of(Spoonerize::Config, Spoonerize.config)
  end

  def test_configure
    assert_nothing_raised do
      Spoonerize.configure do |s|
        s.reverse = true
        s.lazy = true
      end
    end
    assert_equal(true, Spoonerize.config.reverse)
    assert_equal(true, Spoonerize.config.lazy)
  end

  # def test_load_config_file
  #   # create_config_file(test_config_file_name)
  #   refute(Spoonerize.config_file_loaded?)
  #   assert_nothing_raised { Spoonerize.load_config_file(test_config_file_name) }
  #   assert(Spoonerize.config_file_loaded?)
  #   assert_equal(["NONE"], Spoonerize.config.entry.impediments)
  #   assert_equal("Current", Spoonerize.config.file.current_header)
  #   assert_equal("mate", Spoonerize.config.cli.editor)
  # end
end
