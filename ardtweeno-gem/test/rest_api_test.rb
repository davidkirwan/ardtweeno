ENV['RACK_ENV'] = 'test'

require 'rubygems' # Require the REST API Sinatra app
require File.expand_path(File.dirname(__FILE__) + "/../lib/ardtweeno/restapi.rb")
require 'test/unit'
require 'rack/test'
require 'date'


class RESTAPITest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  def app
    RESTAPI
  end
  
  attr_accessor :dispatch, :confdata
  
  def setup
    # Create a DateTime instance
    today = DateTime.now
    theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-" + "%02d" % today.day.to_s()

    
    @dispatcher = Ardtweeno::Dispatcher.instance
    
    @nodeList = Array.new
    
    5.times do |i|
      @nodeList << Ardtweeno::Node.new("node#{i}", "abcdef#{i}")
    end
    
    @dispatcher.nodeManager = Ardtweeno::NodeManager.new({:nodelist => @nodeList})
    
    3.times do |i|
      @dispatcher.store('{"data":[23.5,997.5,65],"key":"abcdef1"}')
    end
    
    # Default values
    @date = theDate
    @hour = ("%02d" % today.hour).to_s
    @minute = ("%02d" % today.min).to_s
  end
  
  
  # Check root redirects to /home successfully
  def test_root
    get "/"
    
    assert_equal("http://example.org/", last_request.url)
    assert last_response.ok?
  end
  
  
  # Check manual create post page loads
  def test_create_post
    
    postURI = @dispatcher.getPostsURI
    
    # Check the form loads ok
    get "/#{postURI}/create/post"
    
    assert_equal("http://example.org/#{postURI}/create/post", last_request.url)
    assert last_response.ok?
    
    # Add a post to the system
    post "/#{postURI}/create/post", 
         params={"title"=>'Test Title', "content"=>'Test Content', "code"=>'Test Code'}
    follow_redirect!
    
    assert_equal("http://example.org/", last_request.url)
    assert last_response.ok?
    
  end
  
  
  # Test 404 raised for non existing pages
  def test_not_found
    get "/testingmctest/not/found"
    
    assert_equal("404 Page Not Found", last_response.body)
    assert not(last_response.ok?)
  end
  
  
  # Test /home
  def test_home
    get "/home"
    
    assert last_response.body.include?("Ardtweeno is an application gateway which bridges")
    assert last_response.ok?
  end
  
  
  # Test /status
  def test_status
    get "/status"
    
    assert last_response.body.include?("System Status")
    assert last_response.ok?
  end


  # Test retrieval of zones
  def test_retrieve_zones
    get "/api/v1/zones", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    
    assert_equal(2, json["found"])
    assert_equal(2, json["total"])
    
    get "/api/v1/zones", params={:zonename=>"testzonez", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(0, json["found"])
    assert_equal(2, json["total"])
    
    get "/api/v1/zones", params={:key=>"455a807bb34b1976bac820b07c263ee81bd267cc"}
    json = JSON.parse(last_response.body)
    assert_equal(1, json["found"])
    assert_equal(2, json["total"])
    
    get "/api/v1/zones/testzone0", params={:zonename=>"testzone0", :key=>"455a807bb34b1976bac820b07c263ee81bd267cc"}
    json = JSON.parse(last_response.body)
    assert_equal(1, json["found"])
    assert_equal(2, json["total"])
    
    get "/api/v1/zones/testzonez", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(0, json["found"])
    assert_equal(2, json["total"])

  end


  # Test retrieval of packets
  def test_retrieve_nodes
    get "/api/v1/nodes", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(5, json["found"])
    assert_equal(5, json["total"])
    
    get "/api/v1/nodes", params={:name=>"node0", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(1, json["found"])
    assert_equal(5, json["total"])
    
    get "/api/v1/nodes", params={:nodekey=>"abcdef1",:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(1, json["found"])
    assert_equal(5, json["total"])
    
    get "/api/v1/nodes", params={:version=>Ardtweeno::VERSION,:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(5, json["found"])
    assert_equal(5, json["total"])
  end

  
  # Test retrieval of packets
  def test_retrieve_packets
    get "/api/v1/packets", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(3, json["found"])
    assert_equal(3, json["total"])
    
    # Test offset
    get "/api/v1/packets", params={:offset=>1, :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(2, json["found"])
    assert_equal(3, json["total"])

    # Test invalid node
    get "/api/v1/packets", params={:node=>"node7", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(0, json["found"])
    assert_equal(0, json["total"])
    
    # Test date
    get "/api/v1/packets", params={:date=>"#{@date}", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(3, json["found"])
    assert_equal(3, json["total"])
    
    # Test hour
    get "/api/v1/packets", params={:hour=>"#{@hour}", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(3, json["found"])
    assert_equal(3, json["total"])
    
    # Test minute
    get "/api/v1/packets", params={:minute=>"#{@minute}", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(3, json["found"])
    assert_equal(3, json["total"])
  end
  
  
  # Test post of packets
  def test_post_packets
    
    # Get initial number of packets in the system
    get "/api/v1/packets", params={:node=>"node1", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    initialNo = json["total"].to_i
    
    # Add a packet
    post "/api/v1/packets", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657",
                             :payload=>'{"key":"abcdef1", "data":[50.0]}'}
    assert last_response.ok?
    
    # Test to ensure it was added successfully
    get "/api/v1/packets", params={:node=>"node1", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(initialNo + 1, json["found"])
    assert_equal(initialNo + 1, json["total"])
    
    # Add another packet
    post "/api/v1/packets", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657",
                             :payload=>'{"key":"abcdef1", "data":[50.0]}'}
    assert last_response.ok?
    
    # Test to once again check if it was added successfully
    get "/api/v1/packets", params={:node=>"node1", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    json = JSON.parse(last_response.body)
    assert_equal(initialNo + 2, json["found"])
    assert_equal(initialNo + 2, json["total"])
    
  end
  
  
  # Test the system start parser command
  def test_system_start
    get "/api/v1/system/start", params={:node=>"node1", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    assert_equal('{"response":true,"running":true}', last_response.body)
    assert last_response.ok?
    
    # Test call with invalid key fails
    get "/api/v1/system/start", params={:node=>"node1", :key=>"898fec74a75a87738dea9f657"}
    assert_equal('{"response":false,"running":true}', last_response.body)
    assert last_response.ok?
  end
  
  
  # Test the system stop parser command
  def test_system_stop
    get "/api/v1/system/stop", params={:node=>"node1", :key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    assert_equal('{"response":true,"running":false}', last_response.body)
    assert last_response.ok?
    
    # Test call with invalid key fails
    get "/api/v1/system/stop", params={:node=>"node1", :key=>"898fec74a75a87738dea9f657"}
    assert_equal('{"response":false,"running":false}', last_response.body)
    assert last_response.ok?
  end
  
  
  # Test the system config command
  def test_system_config
    get "/api/v1/system/config", params={:key=>"1230aea77d7bd38898fec74a75a87738dea9f657"}
    assert last_response.ok?
    
    result = @dispatcher.config.to_json
    
    assert_equal(result, last_response.body)
  end
  
  
  # Test the system status command
  def test_system_status
    get "/api/v1/system/status"
    assert last_response.ok?
    
    result = @dispatcher.status?.to_json
    
    assert_equal(result, last_response.body)
  end
  
  
  # Test the watch list commands
  def test_watch_node
    
    
      
  end
  
  
end