#require 'simplecov'
#SimpleCov.start

#require the Ardtweeno codebase
require File.join(File.dirname(__FILE__), '../lib/ardtweeno.rb')

# Require the test suite
Dir.glob("./test/*_test.rb").each do |file|
  unless file.include? "parser_test.rb" then require file; end
end

# Require the mock
Dir.glob("./test/*_mock.rb").each do |file|
  require file
end
