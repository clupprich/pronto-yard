require 'rspec'
require 'pronto/yard'

RSpec.configure do |config|
  config.expect_with(:rspec)
  config.mock_with(:rspec)
end
