####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno dispatcher test fixtures
#
# @date         14-06-2013
####################################################################################################

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'

ENV['RACK_ENV'] = 'test'


class DispatcherTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  attr_accessor :dispatch, :confdata
  
  
  # Test suite fixtures
  def setup
    
    begin
            
      @confdata = {"dev"=>"/dev/pts/2",
                  "speed"=>9600,
                  "newsURI"=>"b97cb9ae44747ee263363463b7e56",
                  "adminkey"=>"1230aea77d7bd38898fec74a75a87738dea9f657",
                  "db"=>{"dbHost"=>"localhost",
                         "dbPort"=>27017,
                         "dbUser"=>"david",
                         "dbPass"=>"86ddd1420701a08d4a4380ca5d240ba7",
                         "dbName"=>"ardtweeno",
                         "dbPacketsColl"=>"packets"
                         },
                  "zones"=>[{"zonename"=>"testzone0",
                             "zonekey"=>"455a807bb34b1976bac820b07c263ee81bd267cc",
                             "zonenodes"=>["node0","node1"]
                             },
                             {"zonename"=>"testzone1",
                              "zonekey"=>"79a7c75758879243418fe2c87ec7d5d4e1451129",
                              "zonenodes"=>["node2","node3"]
                             }]
                  }
      
      # Inform the Ardtweeno::Dispatcher we are in testing mode so do not run the bootstrap()
      # method as we will be creating instances of all required classes in the fixtures then
      # injecting them into the dispatcher
      Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG, :confdata=>@confdata})
      @dispatch = Ardtweeno::Dispatcher.instance
      
      
      @nodeList = Array.new
      
      5.times do |i|
        @nodeList << Ardtweeno::Node.new("node#{i}", "abcdef#{i}")
      end
      
      @nodemanager = Ardtweeno::NodeManager.new({:nodelist => @nodeList})
      
      @dispatch.nodeManager = @nodemanager
      
      @watchList = Hash.new
      
      @validwatch = {:node=>"node1",
                     :notifyURL=>"http://192.168.1.2:5000/push/node1", 
                     :method=>"GET", 
                     :timeout=>60}
                            
      @nonode = {:notifyURL=>"http://192.168.1.2:5000/push/node1", 
                 :method=>"GET", 
                 :timeout=>60}
                            
      @nomethod = {:node=>"node2",
                   :notifyURL=>"http://192.168.1.2:5000/push/node1",
                   :timeout=>60}
      
      @notimeout = {:node=>"node3",
                    :notifyURL=>"http://192.168.1.2:5000/push/node1", 
                    :method=>"GET"}
      
      @invalidtimeout = {:node=>"node4",
                         :notifyURL=>"http://192.168.1.2:5000/push/node1", 
                         :method=>"GET", 
                         :timeout=>-60}
      
      @invalidmethod = {:node=>"node5",
                        :notifyURL=>"http://192.168.1.2:5000/push/node1", 
                        :method=>"POSTSS", 
                        :timeout=>60}
      
      
    rescue Exception => e
      puts e.message
      puts e.backtrace
      exit
    end
    
  end
  

  # tear down the test fixtures between each test
  def teardown

  end
  
  # Test to ensure the Ardtweeno::Dispatcher#status? is operating correctly
  def test_status
    running = @dispatch.running?
    response = {:running=>running, :cpuload=>0.0, :memload=>0.0}.to_json
    
    assert_equal(@dispatch.status?.to_json, response)
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
    
    # Raises Ardtweeno InvalidData if we send valid JSON but empty data
    assert_raise Ardtweeno::InvalidData do
      @dispatch.store('{"data":[],"key":"abcdef0"}')
    end
    
    # Raises Ardtweeno NodeNotAuthorised if valid JSON, valid Packet but unauthorised node key
    assert_raise Ardtweeno::NodeNotAuthorised do
      @dispatch.store('{"data":[23.5,997.5,65],"key":"500d81aafe637717a52f8650e54206e64da33d27"}')
    end
    
    # Valid Packet
    assert_equal(true, @dispatch.store('{"data":[23.5,997.5,65],"key":"abcdef0"}'))
    
  end


  # Test to ensure we can add a watch to a node correctly
  def test_add_watch
    
    assert_nothing_raised do
      @dispatch.addWatch(@validwatch)
    end
    assert_equal({:watched=>true}, @dispatch.watched?({:node=>"node1"}))
    
    assert_raise Ardtweeno::AlreadyWatched do
      @dispatch.addWatch(@validwatch)  
    end
    
    assert_raise Ardtweeno::InvalidWatch do
      @dispatch.addWatch(@nonode)  
    end
    assert_equal({:watched=>false}, @dispatch.watched?({}))
    
    assert_raise Ardtweeno::InvalidWatch do
      @dispatch.addWatch(@nomethod)  
    end
    assert_equal({:watched=>false}, @dispatch.watched?({:node=>"node2"}))
    
    assert_raise Ardtweeno::InvalidWatch do
      @dispatch.addWatch(@notimeout)  
    end
    assert_equal({:watched=>false}, @dispatch.watched?({:node=>"node3"}))
    
    assert_raise Ardtweeno::InvalidWatch do
      @dispatch.addWatch(@invalidtimeout)  
    end
    assert_equal({:watched=>false}, @dispatch.watched?({:node=>"node4"}))

    assert_raise Ardtweeno::InvalidWatch do
      @dispatch.addWatch(@invalidmethod)  
    end
    assert_equal({:watched=>false}, @dispatch.watched?({:node=>"node5"}))

  end
  
  
  # Test to ensure the Ardtweeno::Dispatcher#getPostsURI is working correctly
  def test_get_posts_URI
    assert_equal(@dispatch.getPostsURI, "b97cb9ae44747ee263363463b7e56")
  end
  

end