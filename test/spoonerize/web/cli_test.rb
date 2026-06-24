require_relative "../../../lib/spoonerize/web/cli"
require_relative "../../test_helper"

class TestWebCli < Test::Unit::TestCase
  include TestHelper

  def setup
    reset_spoonerize_config
  end

  def test_options_default_to_web_app_settings
    cli = Spoonerize::Web::Cli.new([])

    assert_equal(Spoonerize::Web.bind, cli.options[:host])
    assert_equal(Spoonerize::Web.port, cli.options[:port])
  end

  def test_host_and_port_options
    cli = Spoonerize::Web::Cli.new(["--host", "127.0.0.1", "--port", "9292"])

    assert_equal("127.0.0.1", cli.options[:host])
    assert_equal(9292, cli.options[:port])
  end
end
