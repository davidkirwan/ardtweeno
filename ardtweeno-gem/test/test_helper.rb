=begin
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Gateway
#
# @date         2014-08-12
####################################################################################################

This file is part of Ardtweeno.

Ardtweeno is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

Ardtweeno is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
=end

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
