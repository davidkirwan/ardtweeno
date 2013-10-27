####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno::Node test fixtures
#
# @date         2013-08-18
####################################################################################################

require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'

ENV['RACK_ENV'] = 'test'


class NodeTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  
  # Test suite fixtures
  def setup
    
    Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
    
    nodename = "node01"
    nodekey = "0123456789abcdef"
    
    @node = Ardtweeno::Node.new(nodename, nodekey, {:version=>"0.5.0"})
    @packetArray = Array.new
    
    # Create 20 packets and add to the node
    20.times do |i|
      newKey = "0123456789abcdef"
      newData = [23.5, 997.8, 30]    
      newPacket = Ardtweeno::Packet.new(i, newKey, newData)
      
      @packetArray << newPacket
    end

  end
  

  # tear down the test fixtures between each test
  def teardown
    @node = nil
    @packetArray = nil
  end
  
  
  # Test to ensure the Ardtweeno::Node#enqueue is working correctly
  def test_enqueue
    
    # Add the packets to the queue to test the enqueue method
    begin
      @packetArray.each {|i| @node.enqueue(i)}
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
     
    # Test to ensure an attempt to queue an object other than an Ardtweeno::Node raises exception
    assert_raise Ardtweeno::NotAPacket do
      @node.enqueue(Hash.new)
    end
    
  end
  
  
  # Test to ensure the Ardtweeno::Node#dequeue is working correctly
  def test_dequeue
    
    # Test to ensure an attempt to call dequeue on a Node with an empty list raises exception
    assert_raise Ardtweeno::PacketListEmpty do
      @node.dequeue
    end
    
    # Add the packets to the queue to test the enqueue method
    begin
      @packetArray.each {|i| @node.enqueue(i)}
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    
    # Ensure the packets dequeued are the same as the ones we enqueued
    begin
      @packetArray.each {|i| assert_equal(i, @node.dequeue)}
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    
    # Test to ensure an attempt to call dequeue on a Node with an empty list raises exception
    assert_raise Ardtweeno::PacketListEmpty do
      @node.dequeue
    end    
    
  end
  
  
  # Test to ensure the Ardtweeno::Node#to_s method is working correctly
  def test_to_s
    assert_equal(["node01, 0123456789abcdef, Default Description, 0.5.0, []", "[]"], @node.to_s)
  end
  

end