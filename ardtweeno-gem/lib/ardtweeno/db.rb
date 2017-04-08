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
require 'date'
require 'mongo'


module Ardtweeno

  ##
  # Ardtweeno::DB class to handle communication with a MongoDB Database
  #
  class DB
    class << self
    
      attr_accessor :log, :dbconnector, :auth, :coll
      
      ##
      # Ardtweeno::DB#new Constructor
      #
      # * *Args*    :
      #   - ++ -> newNode String, newKey String, options Hash{:description String, 
      # :version String, :sensors Array}
      # * *Returns* :
      #   -
      # * *Raises* :
      #
      def initialize
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        @dbconnector = Mongo::Connection.new(host, port).db(databaseName)
        @auth = @dbconnector.authenticate(my_user_name, my_password)
        @coll = @dbconnector.collection(collName)
      end
     
      def create_connection(conf_data)
	# Create the MongoDB connector instance
	begin
	  @log.debug @confdata["db"]["dbHost"]
	  @log.debug @confdata["db"]["dbPort"]
	  @log.debug @confdata["db"]["dbUser"]
	  @log.debug @confdata["db"]["dbPass"]
	  @log.debug @confdata["db"]["dbName"]
	  @log.debug @confdata["db"]["dbPacketsColl"]
	  
	  @log.debug "Constructing the MongoDB driver instance"
	  
	  db_host = @confdata["db"]["dbHost"]
	  db_port = @confdata["db"]["dbPort"]
	  db_name = @confdata["db"]["dbName"]
	  db_username = @confdata["db"]["dbUser"]
	  db_password = @confdata["db"]["dbPass"]
	  db_collection = @confdata["db"]["dbPacketsColl"]
	  
	  @db = Mongo::Connection.new(db_host, db_port).db(db_name)
	  
	rescue Mongo::ConnectionFailure => e
	  @log.fatal "#{e}"
	rescue Exception => e
	  raise e
	end
      end # end of create_connection
    
      ##
      # Ardtweeno::Dispatcher#flush method for flushing packet data to the Database
      #
      # * *Args*    :
      #   - ++ ->     
      # * *Returns* :
      #   -           true
      # * *Raises* :
      #             Ardtweeno::DBError
      def flush()
	begin
	  @log.debug "Ardtweeno::Dispatcher#flush called"
	
	  db_host = @confdata["db"]["dbHost"]
	  db_port = @confdata["db"]["dbPort"]
	  db_name = @confdata["db"]["dbName"]
	  db_username = @confdata["db"]["dbUser"]
	  db_password = @confdata["db"]["dbPass"]
	  db_collection = @confdata["db"]["dbPacketsColl"]
		  
	  if @db == nil
	    @log.warn "The database connector is not connected to a database!"
	    @log.debug "Attempting to construct the MongoDB driver instance"
	    
	    begin
	      @db = Mongo::Connection.new(db_host, db_port).db(db_name)

	    rescue Mongo::ConnectionFailure => e
	      raise Ardtweeno::DBError, e
	    end
	  end
	  
	  
	  # Ensure we are authenticated to use the MongoDB DB
	  begin
	    @auth = @db.authenticate(db_username, db_password)
	    @coll = @db.collection(db_collection)
	  rescue Mongo::AuthenticationError => e
	    raise Ardtweeno::DBError, e
	  end
	  
	  
	  nodeList = @nodeManager.nodeList
	  packetqueue = Array.new
	  
	  nodeList.each do |i|
	    i.packetqueue.each do |j|
	      data = {
		:key=>j.key,
		:seqNo=>j.seqNo,
		:date=>j.date,
		:hour=>j.hour,
		:minute=>j.minute,
		:node=>j.node,
		:data=>j.data 
	      }
	    
	      packetqueue << data
	    end
	    
	    # Sorted the packetqueue by the sequence number sequentially
	    packetqueue = packetqueue.sort_by {|x| x[:seqNo]} # Not exactly ideal.. but it works ;p
	  end
	  
	  @log.debug "Packetqueue size: #{packetqueue.size}"
	  
	  begin
	    packetqueue.each do |i|
	      @coll.insert(i)
	    end
	  rescue Exception => e
	    raise e
	  end
	  
	  
	rescue Ardtweeno::DBError => e
	  raise e
	end  
	
	return true
      end

    end
  end
end
