require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'

ENV['RACK_ENV'] = 'test'


class DispatcherTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  attr_accessor :dispatch
  
  
  # Test suite fixtures
  def setup
    
    begin
      # Inform the Ardtweeno::Dispatcher we are in testing mode so do not run the bootstrap()
      # method as we will be creating instances of all required classes in the fixtures then
      # injecting them into the dispatcher
      Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
      @dispatch = Ardtweeno::Dispatcher.instance
      
      @nodeList = Array.new
      
      5.times do |i|
        @nodeList << Ardtweeno::Node.new("node#{i}", "abcdef#{i}")
      end
      
      @nodemanager = Ardtweeno::NodeManager.new({:nodelist => @nodeList})
      
      @dispatch.nodeManager = @nodemanager
      
    rescue Exception => e
      puts e.message
      puts e.backtrace
      exit
    end
    
  end
  

  # tear down the test fixtures between each test
  def teardown

  end
  
  # Test to ensure the Ardtweeno::Dispatcher#running? is operating correctly
  def test_running
    assert_equal(false, @dispatch.running?)
    
    @dispatch.start
    assert_equal(true, @dispatch.running?)
    
    @dispatch.stop
    assert_equal(false, @dispatch.running?)
  end
  
  # Test to ensure the Ardtweeno::Dispatcher#start can launch the system correctly
  def test_start
    assert_equal(true, @dispatch.start)
    assert_equal(false, @dispatch.start)
  end
  
  # Test to ensure the Ardtweeno::Dispatcher#stop can terminate the system correctly.
  def test_stop
    @dispatch.start
    assert_equal(true, @dispatch.stop)
    assert_equal(false, @dispatch.stop)
  end
  
  # Test to ensure the Ardtweeno::Dispatcher#store method is operating correctly
  def test_store
    # Test to ensure it will raise an exception if we try to add something other than an
    # Ardtweeno::Packet
    assert_raise TypeError do
      @dispatch.store(Hash.new)
    end
    
    # Raise a JSON ParserError if we send a string but invalid JSON
    assert_raise JSON::ParserError do
      @dispatch.store("{derp:}")
    end
    
    # Raises Ardtweeno InvalidData if we send valid JSON but invalid Packet data
    assert_raise Ardtweeno::InvalidData do
      @dispatch.store("{}")
    end
    
    # Raises Ardtweeno InvalidData if we send valid JSON but invalid Packet data
    assert_raise Ardtweeno::InvalidData do
      @dispatch.store('{"key":"500d81aafe637717a52f8650e54206e64da33d27"}')
    end
    
    # Raises Ardtweeno InvalidData if we send valid JSON but invalid Packet data
    assert_raise Ardtweeno::InvalidData do
      @dispatch.store('{"data":[23.5,997.5,65]}')
    end
    
    # Raises Ardtweeno NodeNotAuthorised if valid JSON, valid Packet but unauthorised node key
    assert_raise Ardtweeno::NodeNotAuthorised do
      @dispatch.store('{"data":[23.5,997.5,65],"key":"500d81aafe637717a52f8650e54206e64da33d27"}')
    end
    
    # Valid Packet
    assert_equal(true, @dispatch.store('{"data":[23.5,997.5,65],"key":"abcdef0"}'))
    
  end
  

end