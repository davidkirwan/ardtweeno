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

require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'

ENV['RACK_ENV'] = 'test'


class PacketTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  
  # Test suite fixtures, setup before each test is executed
  def setup
    
    Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
    
    # Create a DateTime instance
    today = DateTime.now
    @theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-" + "%02d" % today.day.to_s()
    @newHour = ("%02d" % today.hour).to_s
    @newMinute = ("%02d" % today.min).to_s
    @newSecond = ("%02d" % today.sec).to_s
    
    # Instantiate the packetArray
    @packetArray = Array.new
    
    # Create 20 packets and add to the packetList
    20.times do |i|
      newKey = "0123456789abcdef"
      newData = [23.5, 997.8, 30]    
      newPacket = Ardtweeno::Packet.new(i, newKey, newData)
      
      @packetArray << newPacket
    end

  end
  

  # tear down the test fixtures between each test
  def teardown
    @packetArray = nil
  end


  # Test the Ardtweeno::Packet#to_s method
  def test_to_s
    @packetArray.each do |i|
      assert_equal(
      "Packet No: #{i.seqNo} Key: 0123456789abcdef Node: defaultNode Date: #{@theDate} #{@newHour}:#{@newMinute}:#{@newSecond} Data: [23.5, 997.8, 30]",
      i.to_s
      )
    end
  end
  
  # Test the Ardtweeno::Packet#to_json method
  def test_to_json
    str = "{\"date\":\"#{@theDate}\",\"hour\":\"#{@newHour}\",\"minute\":\"#{@newMinute}\",\"second\":\"#{@newSecond}\",\"node\":\"defaultNode\",\"key\":\"0123456789abcdef\",\"seqNo\":0,\"data\":[23.5,997.8,30]}"
    
    assert_equal(str, @packetArray.first.to_json)
    
    # Create JSON objects and compare
    json1 = JSON.parse(str)
    json2 = JSON.parse(@packetArray.first.to_json)
    
    assert_equal(json1, json2)
  end
  

end