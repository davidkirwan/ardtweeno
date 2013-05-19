####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Dispatcher system for the Ardtweeno Mesh Network
#
# @date         30-03-2013
####################################################################################################

# Imports
require 'rubygems'
require 'serialport'
require 'logger'
require 'yaml'
require 'json'
require 'singleton'
require 'ardtweeno'
require 'mongo'

module Ardtweeno
  
  ##
  # Ardtweeno::Dispatcher system for the Ardtweeno Mesh Network
  #
  class Dispatcher
    
    include Singleton
    
    attr_accessor :nodeManager, :parser, :confdata, :nodedata, :db, :auth, :coll, :log, :running
    
    
    ##
    # Constructor for the Ardtweeno::Dispatcher class
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def initialize
      @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
      @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
      
      @running = false
      @parser = nil
      
      unless Ardtweeno.options[:test] ||= false
        @log.debug "Calling bootstrap()"
        bootstrap()
      end
    end


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
          @log.fatal "The database connector is not connected to a database!"
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
        @log.debug "Saving packetqueue to the Database"
        @nodeManager.flush()
        
        
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
    

    ##
    # Ardtweeno::Dispatcher#retrieve_zones method for retrieving zone data from the system
    #
    # * *Args*    :
    #   - ++ ->     params Hash
    # * *Returns* :
    #   -           String in JSON form
    # * *Raises* :
    #    
    def retrieve_zones(params)
      apitimer = Time.now
      
      result = Ardtweeno::API.retrievezones(@confdata, params)
      
      @log.debug "Duration: #{Time.now - apitimer} seconds"
      return result
    end



    ##
    # Ardtweeno::Dispatcher#retrieve_nodes method for retrieving node data from the system
    #
    # * *Args*    :
    #   - ++ ->     params Hash
    # * *Returns* :
    #   -           String in JSON form
    # * *Raises* :
    #    
    def retrieve_nodes(params)
      apitimer = Time.now
      
      result = Ardtweeno::API.retrievenodes(@nodeManager.nodeList, params)
      
      @log.debug "Duration: #{Time.now - apitimer} seconds"
      return result
    end


    
    ##
    # Ardtweeno::Dispatcher#retrieve_packets method for retrieving packet data from the system
    #
    # * *Args*    :
    #   - ++ ->     params Hash
    # * *Returns* :
    #   -           String in JSON form
    # * *Raises* :
    #    
    def retrieve_packets(params)
      apitimer = Time.now
      
      result = Ardtweeno::API.retrievepackets(@nodeManager.nodeList, params)
      
      @log.debug "Duration: #{Time.now - apitimer} seconds"
      return result
    end    
    
    
    ##
    # Ardtweeno::Dispatcher#addWatch method to add a watch on a node
    #
    # * *Args*    :
    #   - ++ ->     params Hash
    # * *Returns* :
    #   -           
    # * *Raises* :
    #    
    def addWatch(params)
      begin
        apitimer = Time.now
        
        if params.has_key? "node" and 
           params.has_key? "notifyURL" and 
           params.has_key? "method" and
           params.has_key? "timeout"
             
          @log.debug "Watch API call seems valid, passing to NodeManager"
          @nodeManager.addWatch(params)
        else
          raise Exception, "Invalid Parameters"
        end
        
        @log.debug "Duration: #{Time.now - apitimer} seconds"
      rescue Exception => e
        raise e
      end
    end 
    
    
    ##
    # Ardtweeno::Dispatcher#store stores a packet retrieved by the API into the system
    #
    # * *Args*    :
    #   - ++ ->   payload String - containing JSON data to match structure of Ardtweeno::Packet
    # * *Returns* :
    #   -         true
    # * *Raises* :
    #            Ardtweeno::InvalidData if data is invalid or TypeError if not valid JSON
    def store(origionalPayload)
      begin
        
        @log.debug "Payload recieved, processing.."
        payload = JSON.parse(origionalPayload)
          
        if payload["data"].nil? then raise Ardtweeno::InvalidData, "Packet missing data" end
        @log.debug "Payload contains a :data key, continuing.."
        if payload["key"].nil? then raise Ardtweeno::InvalidData, "Packet missing key" end
        @log.debug "Payload contains a :key key, continuing.."
          
        @log.debug "Searching for the corresponding Ardtweeno::Node in the system.."
        node = @nodeManager.search({:key=>payload["key"]})
        @log.debug "This packet belongs to a valid node.."
       
        @log.debug "Constructing a new Ardtweeno::Packet from the payload.."
        packet = Ardtweeno::Packet.new(Ardtweeno.nextSeq(), payload["key"], payload["data"])
          
        @log.debug "Adding packet to the node.."
        node.enqueue(packet)
        
        @log.debug "Check if its being watched"
        if @nodeManager.watched?(node)
          @log.debug "There is a watch on this node, pushing notifications"
          @nodeManager.pushNotification(node.node)
        else
          @log.debug "There is no watch associated with this node"
        end
        
        @log.debug "Success!"
        
      rescue Ardtweeno::NotInNodeList => e
        @log.debug "Node is not authorised to communicate with the gateway.."
        raise Ardtweeno::NodeNotAuthorised, "Node is not authorised for this network, ignoring"
      rescue Ardtweeno::InvalidData => e
        raise Ardtweeno::InvalidData, "Data is invalid, ignoring"
      rescue Exception => e
        @log.debug e
        raise e
      end
      
      return true 
    end  
    
    
    ##
    # Ardtweeno::Dispatcher#start which launches the Ardtweeno Mesh Network Router
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         true/false
    # * *Raises* :
    #
    def start()
      
      begin
        unless Ardtweeno.options[:test]   
          unless @running == true
            
            dev = @confdata["dev"]
            speed = @confdata["speed"]
            key = @confdata["adminkey"]
            
            cmd = "/bin/bash -c '/usr/local/bin/node resources/serialparser.js #{dev} #{speed} #{key}'"
                        
            @parser = fork do
              Signal.trap("SIGTERM") { `killall node`; exit }
              `#{cmd}`
            end
            
            @log.debug "Dispatcher#start has been called starting the system up.."
            @running = true
            
            return true
            
          end
        else
          unless @running == true
            @running = true
            return true
          end
        end
      rescue Exception => e
        `killall node`
        raise e
      end
      
      @log.debug "The SerialParser system is already running.. ignoring.."
      return false
      
    end
    
    
    ##
    # Ardtweeno::Dispatcher#stop which stops the Ardtweeno Mesh Network Router
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         true/false
    # * *Raises* :
    #
    def stop()
      
      begin
        unless Ardtweeno.options[:test]        
          unless @running == false
            
            @log.debug "Dispatcher#stop has been called shutting system down.."
            
            Process.kill("SIGTERM", @parser)
            Process.wait
            @parser = nil
            
            @running = false
            return true
            
          end
        else
          unless @running == false
            @running = false
            return true
          end
        end
      rescue Exception => e
        `killall node`
        @parser = nil
        raise e
      end
      
      @log.debug "SerialParser system is inactive.. ignoring.."
      return false

    end
    
    ##
    # Ardtweeno::Dispatcher#reboot which reboots the Ardtweeno Gateway host
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #
    def reboot()
      @log.debug "Dispatcher#reboot has been called, restarting the gateway host.."
      
      cmd = 'ls -l' #'sudo reboot'
      
      rebootFork = fork do
        Signal.trap("SIGTERM") { exit }
        `#{cmd}`
      end
    end
    

    ##
    # Ardtweeno::Dispatcher#running? checks to see if the SerialParser is running
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -          true/false
    # * *Raises* :
    #
    def running?()
      return @running
    end
    

    ##
    # Ardtweeno::Dispatcher#authenticate? Checks the API key provided with that in the DB
    #
    # * *Args*    :
    #   - ++ ->   key String
    # * *Returns* :
    #   -          true/false
    # * *Raises* :
    #
    def authenticate?(key)
      if key == @confdata["adminkey"]
        return true
      else
        
        @confdata["zones"].each do |i|
          if i["zonekey"] == key
            return true
          end
        end
        
        return false
      end
    end
    
    
    ##
    # Ardtweeno::Dispatcher#config returns the configuration as read in from the DB
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -          @confdata
    # * *Raises* :
    #
    def config()
      return @confdata
    end


    ##
    # Ardtweeno::Dispatcher#bootstrap which configures the Dispatcher instance for initial operation
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    private
    def bootstrap()
      
      # Read in the configuration files
      begin
        @log.debug "Reading in the configuration files"
        
        @confdata = Ardtweeno::ConfigReader.load(Ardtweeno::DBPATH)
        @nodedata = Ardtweeno::ConfigReader.load(Ardtweeno::NODEPATH)

      rescue Exception => e
        @log.fatal e.message
        @log.fatal e.backtrace
        raise e
      end
      
      # Create the NodeManager instance
      begin
        @log.debug "Creating an instance of NodeManager inside the Dispatcher"
        
        nodelist = Array.new

        @nodedata.each do |i|
          
          @log.debug i.inspect
          
          noptions = {
            :description => i["description"], 
            :version => i["version"],
            :sensors => i["sensors"]
            }
            
            @log.debug noptions.inspect
            
          nodelist << Ardtweeno::Node.new(i["name"], i["key"], noptions)
        end
        
        nmoptions = {:nodelist => nodelist}
        
        @nodeManager = Ardtweeno::NodeManager.new(nmoptions)
      rescue Exception => e
        @log.debug e.message
        @log.debug e.backtrace
        raise e
      end          
      
      
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
      
      
    end # End of the bootstrap()
    
    
  end
end