require_relative '../../lib/spoonerise'
require_relative '../test_helper'

##
# The test suite for +Cli+.
class TestLog < Test::Unit::TestCase
  include TestHelper

  ##
  # Destroy the working directory and its contents.
  def teardown
    FileUtils.rm_r(test_log_directory) if File.directory?(test_log_directory)
  end

  def test_initialize
    assert_nothing_raised { Spoonerise::Log.new(test_log_file) }
    assert(File.file?(test_log_file))
    assert(File.directory?(test_log_directory))
  end

  def test_contents
    create_log_file
    log = Spoonerise::Log.new(test_log_file)
    assert_equal(fixtures['log_output'].map { |f| f.split(',')}, log.contents)
  end

  def test_write
    create_log_file
    log = Spoonerise::Log.new(test_log_file)
    log.write(fixtures['log_output'])
    assert_equal(2, log.size)
  end

  def test_each
    log = Spoonerise::Log.new(test_log_file)
    assert_nothing_raised { log.each { |i| i } }
  end

  def test_size
    create_log_file
    log = Spoonerise::Log.new(test_log_file)
    assert_equal(1, log.size)
  end
end
