###################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno::Packet test fixtures
#
# @date         2013-08-18
####################################################################################################

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