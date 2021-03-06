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

# Imports
require 'rubygems'
require 'logger'
require 'yaml'
require 'json'
require 'ardtweeno'
require 'typhoeus'


module Ardtweeno
  
  ##
  # Ardtweeno::NodeManager class for the Ardtweeno Mesh Network
  #
  class NodeManager
    
    attr_accessor :nodeList, :zones, :log, :watchlist
    
    
    ##
    # Ardtweeno::NodeManager#new constructor
    #
    # * *Args*    :
    #   - ++ ->   options Hash{:log Logger, :nodelist Array[Ardtweeno::Node]}
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def initialize(options={})
      @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
      @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
      
      @watchlist = Array.new
      
      @nodeList = options[:nodelist] ||= Array.new 
    end


    ##
    # Ardtweeno::NodeManager#flush empties the packetqueue inside each Ardtweeno:Node
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    #
    def flush()
      @nodeList.each do |i|
        i.packetqueue = Array.new
      end
    end



    ##
    # Ardtweeno::NodeManager#addNode adds an Ardtweeno::Node to the managed node list
    #
    # * *Args*    :
    #   - ++ ->   Ardtweeno::Node
    # * *Returns* :
    #   -         true || false
    # * *Raises* :
    #   -         Ardtweeno::NotANode
    #
    def addNode(node)
      if node.class == Ardtweeno::Node
        @log.debug "Size of nodeList before addition: #{@nodeList.size}"
        @nodeList << node
        @log.debug "Size of nodeList after addition: #{@nodeList.size}"
        
        return true
      else
        raise Ardtweeno::NotANode, "Error Ardtweeno::NodeManager#addNode expects an Ardtweeno::Node as a parameter"
      end
    end


    ##
    # Ardtweeno::NodeManager#removeNode removes an Ardtweeno::Node from the managed nodeList
    #
    # * *Args*    :
    #   - ++ ->   {:node, :key}
    # * *Returns* :
    #   -         Ardtweeno::Node
    # * *Raises* :
    #   -         Ardtweeno::NotInNodeList
    #    
    def removeNode(options={})
      @log.debug "removeNode function called, searching for node in list"
      
      begin
        found = search(options)
        @nodeList.delete(found)
        
        return found
        
      rescue Ardtweeno::NotInNodeList
        return nil
      end
      
    end


    ##
    # Ardtweeno::NodeManager#search provides an interface to search the managed Ardtweeno::Node list
    # takes a single parameter hash, expects :node or :key search strings corresponding with the
    # Ardtweeno::Node you wish to search for, and returns this Node if found
    # Raises Ardtweeno::NotInNodeList exception if entry not found in the list
    #
    # * *Args*    :
    #   - ++ ->   options Hash{:node String, :key String}
    # * *Returns* :
    #   -         Ardtweeno::Node
    # * *Raises* :
    #   -         Ardtweeno::NotInNodeList
    #    
    def search(options={})
      key = options[:key] ||= nil
      node = options[:node] ||= nil
      
      if key.nil? and node.nil? then 
        raise Ardtweeno::NotInNodeList, "Error key does not match any Ardtweeno::Node being maintained by this Ardtweeno::NodeManager"
      end
      
      unless key.nil? then 
        @log.debug "Searching the Nodelist for key: " + key
        
        @nodeList.each do |i|
          @log.debug "Comparing #{key} with #{i.key}"
          if i.key == key
            @log.debug "Match found, returning node"
            return i       
          end
        end
        
      end
      
      unless node.nil? then
        @log.debug "Searching the Nodelist for node: " + node
        
        @nodeList.each do |i|
          @log.debug "Comparing #{node} with #{i.node}"
          if i.node == node
            @log.debug "Match found, returning #{i.to_s}"
            return i       
          end
        end
      end
      
      
      @log.debug "Node not found!"
      # Raise NotInNodeList exception if list has been traversed and a corresponding node was
      # not found
      raise Ardtweeno::NotInNodeList, "Error key does not match any Ardtweeno::Node being maintained by this Ardtweeno::NodeManager"
    end
    
    
    ##
    # Ardtweeno::NodeManager#watched? checks if a node has been added to a watchlist
    #
    # * *Args*    :
    #   - ++ ->   Ardtweeno::Node node
    # * *Returns* :
    #   -         True || False
    # * *Raises* :
    #   -         
    #
    def watched?(node)
      
      @watchlist.each do |i|
        
        unless node.nil? then @log.debug "Comparing " + i[:node] + " and " + node; end
        if i[:node] == node
          return true
        end
      end
      
      return false
      
    end
    
    
    ##
    # Ardtweeno::NodeManager#addWatch adds a node to the watchlist
    #
    # * *Args*    :
    #   - ++ ->   String node, Hash watch { String :node, String :notifyURL, 
    #                                       String :method, String :timeouts }
    # * *Returns* :
    #   -        
    # * *Raises* :
    #   -         Ardtweeno::NotInNodeList
    #
    def addWatch(params)
      begin
        node = search({:node=>params[:node]})
        @log.debug "Found Node: " + node.inspect
        
        if watched?(params[:node])
          raise Ardtweeno::AlreadyWatched
        end
        
        watch = { :node=>params[:node], 
                  :notifyURL=> params[:notifyURL],
                  :method=>params[:method], 
                  :timeout=>params[:timeout] 
                }
        
        @log.debug "Adding watch: " + watch.inspect
        
        @watchlist << watch
      
      rescue Ardtweeno::AlreadyWatched => e
        raise e
      rescue Ardtweeno::NotInNodeList => e
        raise e
      rescue Exception => e
        raise e
      end
    end
    
    
    ##
    # Ardtweeno::NodeManager#removeWatch removes a node from the watchlist
    #
    # * *Args*    :
    #   - ++ ->   String node
    # * *Returns* :
    #   -        
    # * *Raises* :
    #   -         Ardtweeno::NotInNodeList
    #
    def removeWatch(node)
      begin
        @log.debug "removeWatch called, querying the node manager for the correct node"
        @log.debug "Searching watchlist for node"
        @log.debug "Size of watchlist before: " + @watchlist.size.to_s
        
        @watchlist.each do |i|
          @log.debug "Comparing #{i[:node]} to #{node}"
          if i[:node] == node
            @log.debug "Node to be deleted has been found, deleting"
            @watchlist.delete(i)
          end
        end
        
        @log.debug "Size of watchlist after: " + @watchlist.size.to_s
        
      rescue Ardtweeno::NotInNodeList => e
        raise e
      end
    end
    
    
    
    ##
    # Ardtweeno::NodeManager#watchList returns the list of nodes being watched
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Array of Hash { String :node, String :notifyURL, 
    #                             String :method, String :timeouts }
    # * *Raises* :
    #   -         
    #
    def watchList
      return @watchlist
    end
    
    
        
    ##
    # Ardtweeno::NodeManager#pushNotification pushes a notification to the node watcher
    #
    # * *Args*    :
    #   - ++ ->   String node
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    #
    def pushNotification(node)
      
      @log.debug "Traversing watchlist"
      @watchlist.each do |i|
        
        @log.debug "Comparing " + i[:node] + " to " + node
                
        if i[:node] == node
          @log.debug "Ensuring the timeout cooloff period is respected"
          now = Time.now.to_i
          
          if i.has_key?(:last_push)
            timeout = i[:last_push] + i[:timeout].to_i
            
            if timeout > now
              @log.debug "We are within the cooloff period, ignoring the push notification"
              return 
            end
          end          
          
          @log.debug "Associated watch found, checking for method " + i[:method]
          if i[:method] == "POST"
            @log.debug "HTTP POST method executing"
            Typhoeus::Request.post(i[:notifyURL], 
                                     :body=> { :title=>"Push notification",
                                               :content=>"#{i[:node]}",
                                               :code=>""})
          elsif i[:method] == "GET"
            @log.debug "HTTP GET method executing" 
            Typhoeus::Request.get(i[:notifyURL], 
                                    :body=> { :title=>"Push notification",
                                              :content=>"#{i[:node]}",
                                              :code=>""})
          end
          
          i[:last_push] = now

        end
      end
      
    end
    
    
    
  end
end
