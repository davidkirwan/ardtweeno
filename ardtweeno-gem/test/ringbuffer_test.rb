####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno::RingBuffer test fixtures
#
# @date         2013-08-17
####################################################################################################

require 'test/unit'
require 'ardtweeno'
require 'rack/test'
require 'logger'
require 'json'


ENV['RACK_ENV'] = 'test'


class RingBufferTest < Test::Unit::TestCase
  
  include Rack::Test::Methods 
  
  
  # Test suite fixtures
  def setup
    @buffer = Array.new
    @size = 50
    @ringbuffer = Ardtweeno::RingBuffer.new(@size)
    
    50.times do |i|
      @buffer.push(i)      
      @ringbuffer.push(i)  
    end
    
  end
  
  
  
  # tear down the test fixtures between each test
  def teardown
    @buffer = nil
    @size = nil
    @ringbuffer = nil
  end
  

  
  # Test to ensure the Ardtweeno::RingBuffer#to_s method functions correctly
  def test_tostring
    assert_equal(@buffer.to_s, @ringbuffer.to_s)
  end
  
  # Test to ensure the Ardtweeo::RingBuffer#to_a method functions correctly
  def test_toarray
    assert_equal(@buffer, @ringbuffer.to_a)
  end
  
  # Test to ensure the Ardtweeno::RingBuffer#clear method functions correctly
  def test_clear
    @ringbuffer.clear
    assert_equal([], @ringbuffer.to_a)
  end
  

end