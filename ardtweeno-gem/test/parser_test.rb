####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno serialparser subsystem test fixtures
#
# @date         05-06-2013
####################################################################################################

require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'ardtweeno'
require 'logger'
require 'json'

ENV['RACK_ENV'] = 'test'


class ParserTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  attr_accessor :parser, :mock, :modem, :validdata, :invaliddata, :validdata_invalidnode, :thenode,
                :themanager
  
  
  # Test suite fixtures
  def setup
    
    Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
    
    @modem = fork do
      Signal.trap("SIGTERM") { `killall tty0tty`; exit }
      `test/debug/tty0tty-1.1/pts/tty0tty`
    end
    
    sleep(1)
        
    one = "/dev/pts/2"
    two = "/dev/pts/3"
    
    begin
      @mock = SerialDeviceMock.new(one, 9600, 100)
      @parser = Ardtweeno::SerialParser.new(two, 9600, 100)
    rescue Exception => e
      puts e.message
      `killall tty0tty`
      exit
    end
    
    @validdata = Ardtweeno::Packet.new(1, "abcvalidkey", [1,2,3])
    @validdata_invalidnode = Ardtweeno::Packet.new(2, "abcinvalidkey", [1,2,3])
    @invaliddata = {}
    
    @thenode = Ardtweeno::Node.new("validnode", "abcvalidkey", {:sensors=>["a", "b", "c"]})
    @themanager = Ardtweeno::NodeManager.new
    @themanager.addNode(thenode)
    
  end
  

  # tear down the test fixtures between each test
  def teardown
    @validdata = nil
    @validdata_invalidnode = nil
    @invaliddata = nil
    @themanager = nil
    @thenode = nil
    @mock.close
    @parser.close
    Process.kill("SIGTERM", @modem)
    Process.wait
  end


  # Test Ardtweeno::SerialParser#store can store data correctly
  def test_parser_store
    
    # Valid data, with no NodeManager should raise Ardtweeno::ManagerNotDefined
    assert_raise Ardtweeno::ManagerNotDefined do
      @parser.store(@validdata)
      
    end
    
    # Now add the manager to the SerialParser
    @parser.manager = @themanager

    # Valid data, with valid NodeManager, but invalid node should raise Ardtweeno::NodeNotAuthorised
    assert_raise Ardtweeno::NodeNotAuthorised do
      @parser.store(@validdata_invalidnode)
    end
      
    # Valid data, with valid NodeManager, and valid node should store successfully
    assert_equal(true, @parser.store(@validdata))
      
    # Invalid data, should raise Ardtweeno::InvalidData exception
    assert_raise Ardtweeno::InvalidData do
      @parser.store(@invaliddata)
    end
    
  end


  # Check Ardtweeno::SerialParser#write operates correctly
  def test_parser_write
    
    #Valid output
    testData = {"seqNo" => 5, "data" => [23.5, 997.5, 65], "key" => "1234567890abcdef" }.to_json
    assert_equal(true, @parser.write(testData))
    val = @mock.read
    assert_equal('{"seqNo":5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}', val)
    
    # Invalid Input
    testData2 = '{seqNo:5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}'
    assert_equal(false, @parser.write(testData2))

  end  


  # Check Ardtweeno::SerialParser#read can read data on serial device correctly
  def test_parser_read
    
    # Valid input
    testData = {"seqNo" => 5, "data" => [23.5, 997.5, 65], "key" => "1234567890abcdef" }.to_json
    @mock.write(testData)
    val = @parser.read
    assert_equal('{"seqNo":5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}', val)
    
    # Invalid Input
    testData2 = '{seqNo:5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}'
    @mock.write(testData2)
    val2 = @parser.read
    assert_equal('{}', val2)

  end


  # Check Ardtweeno::SerialParser#valid_json? can validate JSON data correctly
  def test_parser_validate_input 
    valid = '{"seqNo":5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}'
    assert_equal(true, Ardtweeno::SerialParser.valid_json?(valid))
    
    invalid = '{seqNo:5,"data":[23.5,997.5,65],"key":"1234567890abcdef"}' 
    assert_equal(false, Ardtweeno::SerialParser.valid_json?(invalid))  
  end
  
  
  # Check Ardtweeno::SerialParser#nextSeq returns unique values each call
  def test_parser_next_seq 
    20.times do |i|
      assert_equal(i, @parser.nextSeq)  
    end
  end

end
