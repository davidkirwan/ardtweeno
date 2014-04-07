####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno dispatcher system
#
# @date         2013-08-18
####################################################################################################

# Imports
require 'serialport'
require 'logger'
require 'yaml'
require 'json'
require 'singleton'
require 'mongo'
require 'ardtweeno'

module Ardtweeno
  
  ##
  # Ardtweeno::Dispatcher system for the Ardtweeno Mesh Network
  #
  class Dispatcher
    
    include Singleton
    
    attr_accessor :nodeManager, :parser, :confdata, :nodedata, :db, :auth, :coll, :log, :running, :posts
    
    
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
      
      @statusbuffer = Ardtweeno::RingBuffer.new(90)
        
      if Ardtweeno.options[:test]
        @confdata = Ardtweeno.options[:confdata]
      else
        @log.debug "Calling bootstrap()"
        bootstrap()
      end
    end


    
    ##
    # Ardtweeno::Dispatcher#constructPunchcard method for constructing the punchcard graph
    #
    # * *Args*    :
    #   - ++ ->     
    # * *Returns* :
    #   -           Array data containing the 168 hourly packet totals for the last week,
    #               Array of strings containing the names of the last 7 days
    # * *Raises* :
    #             
    #
    def constructPunchcard(params)
      theData, theDays, theDateRange = Ardtweeno::API.buildPunchcard(@nodeManager.nodeList, params)
      
      return theData, theDays, theDateRange
    end
    
    
    
    ##
    # Ardtweeno::Dispatcher#constructTopology method for constructing the topology graph
    #
    # * *Args*    :
    #   - ++ ->     Hash params, not really used for the moment
    # * *Returns* :
    #   -           String containing the Raphael.js code to generate the graph
    # * *Raises* :
    #             
    #
    def constructTopology(params=nil)
      apitimer = Time.now
      
      nodes = Ardtweeno::API.retrievenodes(@nodeManager.nodeList, params)
      zones = Ardtweeno::API.retrievezones(@confdata, params)
      
      topology = Ardtweeno::API.parseTopology(zones, nodes)
      result = Ardtweeno::API.buildTopology(topology)
      
      @log.debug "Duration: #{Time.now - apitimer} seconds"
      return result
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
    # Ardtweeno::Dispatcher#watchList method to return Array of Hash containing watched node information
    #
    # * *Args*    :
    #   - ++ ->    
    # * *Returns* :
    #   -         Array of Hash { String :node, String :notifyURL, 
    #                             String :method, String :timeouts }
    # * *Raises* :
    #    
    def watchList
      return {:watched=>@nodeManager.watchList}
    end


    
    ##
    # Ardtweeno::Dispatcher#watched? method to discover if a node is being watched
    #
    # * *Args*    :
    #   - ++ ->     params Hash containing: {:node String name of the node}
    # * *Returns* :
    #   -         Hash {watched=>true|false}  
    # * *Raises* :
    #
    def watched?(params)
      return {:watched=>@nodeManager.watched?(params[:node])}
    end
    
    
    
    ##
    # Ardtweeno::Dispatcher#addWatch method to add a watch on a node
    #
    # * *Args*    :
    #   - ++ ->     params Hash containing: {:node String name of the node,
    #                                        :notifyURL String URL to post a push notification to 
    #                                        :method String either GET or PUSH to indicate HTTP methods
    #                                        :timeout Fixnum the timeout in seconds between push notifications }
    # * *Returns* :
    #   -           
    # * *Raises* :
    #             Ardtweeno::InvalidWatch if params do not adhere to specification
    #             Ardtweeno::AlreadyWatched if node is already on a watchlist
    #
    def addWatch(params)
      begin
        apitimer = Time.now
        
        params = params.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
        
        if params.has_key? :node and 
           params.has_key? :notifyURL and 
           params.has_key? :method and
           params.has_key? :timeout
          
          
          unless params[:method] == "GET" or params[:method] == "POST"
            raise Ardtweeno::InvalidWatch, "Invalid Parameters"
          end
          
          unless params[:timeout].to_i >= 0
            raise Ardtweeno::InvalidWatch, "Invalid Parameters"
          end
          
          @log.debug "Watch API call seems valid, passing to NodeManager"
          @nodeManager.addWatch(params)
        else
          @log.debug params.inspect
          raise Ardtweeno::InvalidWatch, "Invalid Parameters"
        end
        
        @log.debug "Duration: #{Time.now - apitimer} seconds"
        
      rescue Ardtweeno::AlreadyWatched => e
        raise e, "This node already has a watch associated with it"
      rescue Ardtweeno::InvalidWatch => e
        raise e, "Invalid Parameters"
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
          
        if payload["data"].nil? then raise Ardtweeno::InvalidData, "Packet missing data"; end
        @log.debug "Payload contains a :data key, continuing.."
        if payload["data"].empty? then raise Ardtweeno::InvalidData, "Packet data empty"; end
        @log.debug "Payload data is not empty, continuing.."
        if payload["key"].nil? then raise Ardtweeno::InvalidData, "Packet missing key"; end
        @log.debug "Payload contains a :key key, continuing.."
          
        @log.debug "Searching for the corresponding Ardtweeno::Node in the system.."
        node = @nodeManager.search({:key=>payload["key"]})
        @log.debug "This packet belongs to a valid node.."
       
        @log.debug "Constructing a new Ardtweeno::Packet from the payload.."
        packet = Ardtweeno::Packet.new(Ardtweeno.nextSeq(), payload["key"], payload["data"])
          
        @log.debug "Adding packet to the node.."
        node.enqueue(packet)
        
        @log.debug "Check if its being watched"
        if @nodeManager.watched?(node.node)
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
            
            begin
              serialparser = Ardtweeno::SerialParser.new(dev, speed, 100, {:log=>@log, :level=>@log.level})
            rescue Exception => e
              @log.fatal "Ardtweeno::Dispatcher#start Fatal Error constructing the SerialParser:"
              @running = false
              return false
            end
                      
            @parser = Thread.new do
                           
              begin
                loop do
                  serialparser.listen(key)
                end
                
              rescue Exception => e
                @log.debug e.message
                serialparser.close
                @running = false
                @parser.kill
                @parser = nil
                
              end
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
        @parser.kill
        @parser = nil
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
            
            @parser.kill
            @parser = nil
            
            @running = false
            @log.debug "Dispatcher#stop has been called shutting system down.."
            
            return true
            
          end
        else
          unless @running == false
            @running = false
            return true
          end
        end
      rescue Exception => e
        @parser.kill
        @parser = nil
        raise e
      end
      
      @log.debug "SerialParser system is inactive.. ignoring.."
      return false

    end


    
    ##
    # Ardtweeno::Dispatcher#reboot which flushes data then reboots the Ardtweeno Gateway host
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
      sh "#{cmd}"
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
    def diskUsage()
      return Ardtweeno::API.diskUsage
    end
    
    
    
    ##
    # Ardtweeno::Dispatcher#statuslist returns a Array of Hash containing system statuses for
    #                                  the last 15 minutes
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Array [Hash {Boolean running, String cpuload, String memload}]
    # * *Raises* :
    #
    def statuslist()
      @log.debug "Ardtweeno::Dispatcher#statuslist executing"
      begin
        rawdata = @statusbuffer.to_a
        
        cpu = Array.new
        mem = Array.new
        running = Array.new
        
        now = (Time.now.to_i * 1000) # Get the milliseconds since the epoch
        start = now - (rawdata.size * 10000) # Get the milliseconds from the start of the buffer
        
        rawdata.each do |i|
          cpu << [start, i[:cpuload]]
          mem << [start, i[:memload]]
          running << [start, i[:running]]
          
          start += 10000
        end
        
        cpuseries = {:label=>"CPU &#37;", :data=>cpu, :color=>"#ED0E0E"}
        memseries = {:label=>"MEM &#37;", :data=>mem, :color=>"#0E7AED"}
        runningseries = {:label=>"Active", :data=>running}
        
        return [cpuseries, memseries, runningseries]
        
      rescue Exception => e
        raise e
      end
    end
    
    
    
    ##
    # Ardtweeno::Dispatcher#status? returns the system status of the Ardtweeno Gateway host
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Hash {Boolean running, String cpuload, String memload}
    # * *Raises* :
    #    
    def status?()
      @log.debug "Ardtweeno::Dispatcher#status? executing"
      begin
        unless Ardtweeno.options[:test] ||= false
          theResponse = Ardtweeno::API.status
          theResponse[:running] = @running
          return theResponse
        else # When in testing mode, return blank data
          theResponse = {:running=>@running,
                         :cpuload=>0.0,
                         :memload=>0.0}
                           
          @log.debug theResponse.inspect
          return theResponse
        end
      rescue Exception => e
        raise e
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
        return true, {:role=>"admin"}
      else
        
        @confdata["zones"].each do |i|
          if i["zonekey"] == key
            i[:role] = "zone"
            return true, i
          end
        end
        
        return false, {}
      end
    end
    

    
    ##
    # Ardtweeno::Dispatcher#getPostsURI returns the front page news URI ~/.ardtweeno/conf.yaml 
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -          String which makes up the news post URI ie "/randomhash/create/post"
    # * *Raises* :
    #
    def getPostsURI()
      return @confdata["newsURI"]
    end
    
    
    
    ##
    # Ardtweeno::Dispatcher#getPosts returns the front page news posts loaded from ~/.ardtweeno/posts.yaml 
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -          Array of Hash containing post data
    # * *Raises* :
    #
    def getPosts()
      unless @posts.nil? or @posts.empty?
        return @posts["posts"]
      else
        return Array.new
      end
    end

    
    
    ##
    # Ardtweeno::Dispatcher#savePosts saves a post to ~/.ardtweeno/posts.yaml 
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -          
    # * *Raises* :
    #
    def savePosts(newPosts)
      @posts["posts"] = newPosts
      Ardtweeno::ConfigReader.save(@posts, Ardtweeno::POSTPATH)
    end

    
    
    ##
    # Ardtweeno::Dispatcher#config returns the configuration as read in from the confg.yaml configuration 
    # file
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
    def bootstrap
      
      # Create a thread which updates the statusbuffer
      @statusthread = Thread.new do
        loop do
          @statusbuffer.push(status?)
          sleep(10)
        end
      end
      
      # Read in the configuration files
      begin
        @log.debug "Reading in the configuration files"
        
        @confdata = Ardtweeno::ConfigReader.load(Ardtweeno::DBPATH)
        @nodedata = Ardtweeno::ConfigReader.load(Ardtweeno::NODEPATH)
        @posts = Ardtweeno::ConfigReader.load(Ardtweeno::POSTPATH)

      rescue Exception => e
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
    
    
    private :bootstrap
    
  end
end
