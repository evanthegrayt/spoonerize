require 'rspec'
require_relative '../lib/spoonerise'

RSpec.configure do |config|
  config.color = true
  config.formatter = :documentation
end

