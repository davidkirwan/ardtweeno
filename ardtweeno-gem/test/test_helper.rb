####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Gateway test helper
#
# @date         05-06-2013
####################################################################################################

#require the Ardtweeno codebase
require File.join(File.dirname(__FILE__), '../lib/ardtweeno.rb')

ENV['RACK_ENV'] = 'test'

# Require the test suite
Dir.glob("./test/*_test.rb").each do |file|
  require file
end

# Require the mock
Dir.glob("./test/*_mock.rb").each do |file|
  require file
end
