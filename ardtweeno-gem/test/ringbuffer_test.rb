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