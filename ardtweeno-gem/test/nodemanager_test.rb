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


class NodeManagerTest < Test::Unit::TestCase

  include Rack::Test::Methods
  
  
  # Test suite fixtures
  def setup
    
    Ardtweeno.setup({:test=>true, :log=>Logger.new(STDOUT), :level=>Logger::DEBUG})
    
    @init = Array.new
    
    6.upto(10) do |i|
      @init << Ardtweeno::Node.new("node#{i}", "abcdef#{i}")
    end
    
    @nodeList = Array.new
    
    5.times do |i|
      @nodeList << Ardtweeno::Node.new("node#{i}", "abcdef#{i}")
    end
    
    @nodemanager = Ardtweeno::NodeManager.new({:nodelist => @init})
    
    @removeTest = Ardtweeno::Node.new("removetest", "testremove")

    @watch = { :node=>@init[2], :notifyURL=> "http://example.org/",
      :method=>"POST", :timeout=>"60" }

  end
  

  # tear down the test fixtures between each test
  def teardown
    @nodemanager = nil
    @init = nil
    @nodeList = nil
    @removeTest = nil
    @watch = nil
  end
  
  
  # Test to ensure the Ardtweeno::NodeManager#addNode method can successfully add
  # an Ardtweeno::Node to the nodelist field. 
  def test_addNode
    
    # Check to ensure each Node is successfully added to the system
    @nodeList.each do |i|
      assert_equal(true, @nodemanager.addNode(i))   
    end
    
    finalArray = @init #+ @nodeList
    # nodeList should contain the initial values and the ones we just added    
    assert_equal(finalArray, @nodemanager.nodeList)
    
    # Test to ensure it will raise an exception if we try to add something other than an
    # Ardtweeno::Node
    assert_raise Ardtweeno::NotANode do
      @nodemanager.addNode(Hash.new)
    end
  end
  
  
  # Test to ensure the Ardtweeno::NodeManager#removeNode can successfully find and then
  # delete the specified Ardtweeno::Node from the managed nodeList
  def test_remove
    
    # Add the testNode    
    @nodemanager.addNode(@removeTest)
    # Before the removal
    assert_equal(6, @nodemanager.nodeList.size)
    testNode = @nodemanager.removeNode({:node => "removetest"})
    assert_equal(testNode, @removeTest)
    # After the removal
    assert_equal(5, @nodemanager.nodeList.size)
    
    # Add the testNode    
    @nodemanager.addNode(@removeTest)
    # Before the removal
    assert_equal(6, @nodemanager.nodeList.size)
    testNode = @nodemanager.removeNode({:key => "testremove"})
    assert_equal(testNode, @removeTest)
    # After the removal
    assert_equal(5, @nodemanager.nodeList.size)
    
    # Test to ensure a search for a node not in the list raises an exception
    assert_raise Ardtweeno::NotInNodeList do
      @nodemanager.search({})
    end
    
  end
  
  
  # Test to ensure the Ardtweeno::NodeManager#search method can successfully find
  # an Ardtweeno::Node in the nodeList
  def test_search
    
    # Search using key
    @init.each do |i|
      assert_equal(i, @nodemanager.search({:key => i.key}))
    end
    
    # Search using node name
    @init.each do |i|
      assert_equal(i, @nodemanager.search({:node => i.node}))
    end
    
    # Test to ensure a search for a node not in the list raises an exception
    assert_raise Ardtweeno::NotInNodeList do
      @nodemanager.search({:key => @nodeList[0].key})
    end
    
    # Test to ensure a search for a node not in the list raises an exception
    assert_raise Ardtweeno::NotInNodeList do
      @nodemanager.search({:node => @nodeList[0].node})
    end
    
    # Test to ensure a search for a node not in the list raises an exception
    assert_raise Ardtweeno::NotInNodeList do
      @nodemanager.search({})
    end
    
  end
  
  
  # Test to ensure the watched? works correctly
  def test_watched?
    # Check to ensure they are all unwatched initially
    @init.each do |i|
      assert_equal(false, @nodemanager.watched?(i))
    end
    
    # Add a watch and retest
    @nodemanager.addWatch({ :node=>"node6", 
                            :notifyURL=>"http://example.com", 
                            :timeout=>"60", 
                            :method=>"POST"
                          })
    
    assert_raise Ardtweeno::AlreadyWatched do
      # Attempt to add a second watch
      @nodemanager.addWatch({ :node=>"node6", 
                            :notifyURL=>"http://example.com", 
                            :timeout=>"60", 
                            :method=>"POST"
                          })
    end
    
    assert_nothing_raised do
      assert_equal(true, @nodemanager.watched?("node6"))  
    end
    
    assert_nothing_raised do
      @nodemanager.removeWatch("node6")  
    end
    
    assert_nothing_raised do
      assert_equal(false, @nodemanager.watched?("node6"))  
    end
    
  end
  

end