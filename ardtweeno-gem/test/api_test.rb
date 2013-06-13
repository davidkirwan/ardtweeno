require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'
require 'date'

ENV['RACK_ENV'] = 'test'


class APITest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  attr_accessor :dispatch, :nodelist, :params, :date, :hour, :minute
  
  
  # Test suite fixtures
  def setup
    
    begin
      # Inform the Ardtweeno::Dispatcher we are in testing mode so do not run the bootstrap()
      # method as we will be creating instances of all required classes in the fixtures then
      # injecting them into the dispatcher
      Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
      @dispatch = Ardtweeno::Dispatcher.instance
      
      
      # Create a DateTime instance
      today = DateTime.now
      theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-" + "%02d" % today.day.to_s()
      
      # Default values
      @date = theDate
      @hour = ("%02d" % today.hour).to_s
      @minute = ("%02d" % today.min).to_s      
      
      @nodeList = Array.new
      
      5.times do |i|
        @nodeList << Ardtweeno::Node.new("node#{i}", "abcdef#{i}", {:version=>"0.5.0"})
      end
      
      nodemanager = Ardtweeno::NodeManager.new({:nodelist => @nodeList})
      
      @dispatch.nodeManager = nodemanager
      
      @confdata = {"dev"=>"/dev/pts/2",
                  "speed"=>9600,
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
      
      @params = { :empty=> {},
                  :withnode=> {:node=>"node1"},
                  :withinvalidnode=> {:node=>"node7"},
                  :withoffset=> {:offset=>2},
                  :withnegativeoffset=> {:offset=>-32},
                  :withoffsetbordertest=> {:offset=>5},
                  :withlength=> {:length=>2},
                  :withzerolength=> {:length=>0},
                  :withlargelength=> {:length=>500},
                  :withsort=> {:sort=>"asc"},
                  :withsortreverse=> {:sort=>"desc"},
                  :withdate=> {:date=>@date},
                  :withhour=> {:hour=>@hour},
                  :withdatewrong=> {:date=>"11-111-1111"},
                  :withhourwrong=> {:hour=>"022"},
                  :withminute=> {:minute=>@minute},
                  :withminutewrong=> {:minute=>"022"},
                  :withseqno=> {:seqno=>35},
                  :withseqnowrong=> {:seqno=>50000},
                  :withversion=> {:version=> "0.5.0"},
                  :withversionwrong=> {:version=> "0.0.0"},
                  :withname=> {:name=>"node0"},
                  :withnamewrong=> {:name=>"node28"},
                  :withnodekey=> {:nodekey=>"abcdef1"},
                  :withnodekeywrong=> {:nodekey=>"fffffffffff"},
                  :withzonename=> {:zonename=>"testzone0"},
                  :withoutzonename=> {:zonename=>"notazonename"}
                }
      
      5.times do |i|
        @dispatch.store('{"data":[23.5,997.5,65],"key":"abcdef1"}')
      end
      
    rescue Exception => e
      puts e.message
      puts e.backtrace
      exit
    end
    
  end
  

  # tear down the test fixtures between each test
  def teardown
    
  end
  
  
  # Test the retrievezones method
  def test_retrievezones
    results = Ardtweeno::API.retrievezones(@confdata, @params[:withzonename])
    assert_equal(1, results[:zones].size)
    
    results = Ardtweeno::API.retrievezones(@confdata, @params[:withoutzonename])
    assert_equal(0, results[:zones].size)
    
    results = Ardtweeno::API.retrievezones(@confdata, @params[:empty])
    assert_equal(2, results[:zones].size)
    
  end
  
  
    
  # Test the retrievenodes method
  def test_retrievenodes
    results = @dispatch.retrieve_nodes(@params[:empty])
    assert_equal(5, results[:nodes].size)
  end
  
  
  # Test the retrievepackets method
  def test_retrievepackets
    results = @dispatch.retrieve_packets(@params[:withnode])
    assert_equal(5, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withinvalidnode])
    assert_equal(0, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:empty])
    assert_equal(5, results[:packets].size)
    
  end
  
  
  # Test the handleVersion method
  def test_handleVersion
    results = @dispatch.retrieve_nodes(@params[:withversion])
    assert_equal(5, results[:nodes].size)

    results = @dispatch.retrieve_nodes(@params[:withversionwrong])
    assert_equal(0  , results[:nodes].size)
  end
  
  
  # Test the handleName method
  def test_handleName
    results = @dispatch.retrieve_nodes(@params[:withname])
    assert_equal(1, results[:nodes].size)

    results = @dispatch.retrieve_nodes(@params[:withnamewrong])
    assert_equal(0  , results[:nodes].size)
  end
  
  
  # Test the handleNodeKey method
  def test_handleNodeKey
    results = @dispatch.retrieve_nodes(@params[:withnodekey])
    assert_equal(1, results[:nodes].size)

    results = @dispatch.retrieve_nodes(@params[:withnodekeywrong])
    assert_equal(0  , results[:nodes].size)
  end
  
  
  # Test the handleSeqNo method
  def test_handleSeqNo
    results = @dispatch.retrieve_packets(@params[:withseqno])   
    assert_equal(1, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withseqnowrong])
    assert_equal(0, results[:packets].size)
  end
  
  # Test the handleMinute method
  def test_handleMinute
    results = @dispatch.retrieve_packets(@params[:withminute])
    assert_equal(5, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withminutewrong])
    assert_equal(0, results[:packets].size)
  end
  
  
  # Test the handleHour method
  def test_handleHour
    results = @dispatch.retrieve_packets(@params[:withhour])
    assert_equal(5, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withhourwrong])
    assert_equal(0, results[:packets].size)
  end
  
  
  # Test the handleDate method
  def test_handleDate
    results = @dispatch.retrieve_packets(@params[:withdate])
    assert_equal(5, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withdatewrong])
    assert_equal(0, results[:packets].size)
  end
  
  
  # Test the handleOffset method
  def test_handleOffset
    results = @dispatch.retrieve_packets(@params[:withoffset])
    assert_equal(3, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withoffsetbordertest])
    assert_equal(0, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withnegativeoffset])
    assert_equal(5, results[:packets].size)

  end

  
  # Test the handleLenght method
  def test_handleLength
    results = @dispatch.retrieve_packets(@params[:withlength])
    assert_equal(2, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withzerolength])
    assert_equal(0, results[:packets].size)
    
    results = @dispatch.retrieve_packets(@params[:withlargelength])
    assert_equal(5, results[:packets].size)

  end
  
  
  # Test the handleSort method
  def test_handleSort
    results = @dispatch.retrieve_packets(@params[:withsort])
    assert_equal(5, results[:packets].size)
    
    assert_block do
      val1 = results[:packets][0].seqNo
      val2 = results[:packets][4].seqNo
      
      if val2 > val1 then return true; else return false; end
    end
    
    
    results = @dispatch.retrieve_packets(@params[:withsortreverse])
    assert_equal(5, results[:packets].size)
    
    assert_block do
      val1 = results[:packets][0].seqNo
      val2 = results[:packets][4].seqNo
      
      if val2 < val1 then return true; else return false; end
    end
    
  end

end