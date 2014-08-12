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

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'
require File.join(File.expand_path(File.dirname(__FILE__)), '/serialport_mock.rb')

ENV['RACK_ENV'] = 'test'


class ParserTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  
  # Test suite fixtures
  def setup
    
    Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
    
    before = Dir.glob("/dev/pts/*")
    
    @modem = Thread.new do
      `test/debug/tty0tty-1.1/pts/tty0tty`
    end
    
    sleep(1)
    
    after = Dir.glob("/dev/pts/*")    
    after.reject! {|i| before.include? i}
    puts after[0]
    puts after[1]
    
    theParser = after[0]
    theMock = after[1]    
    
    options = {:log=>Logger.new(STDOUT), :level=>Logger::DEBUG, :testing=>true}
    
    begin
      @parser = Ardtweeno::SerialParser.new(theParser, 9600, 100, options)
      @mock = SerialDeviceMock.new(theMock, 9600, 100)
    rescue Exception => e
      puts e.message
      `killall tty0tty`
      exit
    end
    
    @validdata = Ardtweeno::Packet.new(1, "abcvalidkey", [1,2,3])
    @validdata_invalidnode = Ardtweeno::Packet.new(2, "abcinvalidkey", [1,2,3])
    @invaliddata = {}
    
  end
  

  # tear down the test fixtures between each test
  def teardown
    `killall tty0tty`
    @validdata = nil
    @validdata_invalidnode = nil
    @invaliddata = nil
    @mock.close
    @parser.close
    @modem.kill
  end


  # Test the Ardtweeno::SerialParser#postToAPI method to ensure it is posting the right data
  def test_postToAPI
    key = "abc"
    testdata = '{"test":"abcdefg"}'
    compareTo = {:key=>key, :payload=>testdata}
    
    @mock.write(testdata)
    result = @parser.listen(key)
    
    assert_equal(result, compareTo)
  end
  

end
