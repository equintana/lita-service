require 'simplecov'
require 'coveralls'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

require 'lita-service'
require 'lita/rspec'
require 'pry'

# A compatibility mode is provided for older plugins upgrading from
# Lita 3. Since this plugin was generated with Lita 4,
# the compatibility mode should be left disabled.
Lita.version_3_compatibility_mode = false
