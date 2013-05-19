####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Core functions for the Ardtweeno SerialParser system
#
# @date         15-11-2012
####################################################################################################

# Imports
require 'rubygems'
require 'serialport'
require 'logger'
require 'yaml'
require 'json'

module Ardtweeno
  
  ##
  # Ardtweeno::SerialParser class for the Ardtweeno system
  #
  class SerialParser
    
    attr_accessor :sp, :log, :seqNo, :manager
    
    ##
    # Ardtweeno::SerialParser#new constructor for the Ardtweeno system
    #
    # * *Args*    :
    #   - ++ ->   device String, speed Fixnum, timeout Fixnum, {:log}
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    # 
    def initialize(dev, speed, timeout, options={})
      @log = options[:log] ||= Logger.new(STDOUT)
      @log.level = Logger::WARN
      
      @log.debug "Creating instance of Ardtweeno::SerialParser"
      
      # Injection of NodeManager into the SerialParser
      @manager = options[:manager] ||= nil
      
      @seqNo = 0
      
      begin
        @sp = SerialPort.new(dev, speed)
        @sp.read_timeout = timeout
      rescue Exception => e
        @log.fatal e.message
        raise e
      end
    end
    
    
    
    ##
    # Ardtweeno::SerialParser#read Reads data from the active SerialPort device and then validates
    # returns data if valid JSON, otherwise returns empty JSON hash
    #
    # * *Args*    :
    #   - ++ ->   String, Fixnum, Fixnum, {:log}
    # * *Returns* :
    #   -         JSON if valid, otherwise empty JSON hash
    # * *Raises* :
    #   -         
    # 
    def read()
      data = @sp.read
      
      @log.debug "Validating JSON data"
      if SerialParser.valid_json?(data)
        @log.debug "Data is valid JSON"
        return data
      else
        @log.debug "Data is invalid JSON"
        return '{}'
      end
   
    end
    
    
    ##
    # Ardtweeno::SerialParser#convert Converts JSON string to Ardtweeno::Packet if possible
    #
    # * *Args*    :
    #   - ++ ->   JSON String
    # * *Returns* :
    #   -         Ardtweeno::Packet
    # * *Raises* :
    #   -         Ardtweeno::InvalidData
    #
    # {"seqNo":5,"data":[23.5,997.5,65],"key":"1234567890abcdef"} 
    def convert(packetdata) 
      if packetdata["data"].nil? then raise Ardtweeno::InvalidData, "Packet missing data" end
      if packetdata["key"].nil? then raise Ardtweeno::InvalidData, "Packet missing key" end
        
      return Ardtweeno::Packet.new(nextSeq(), packetdata["key"], packetdata["data"])
    end
    
    
    ##
    # Ardtweeno::SerialParser#store initiates the storage of an Ardtweeno::Packet
    #
    # * *Args*    :
    #   - ++ ->   Ardtweeno::Packet
    # * *Returns* :
    #   -         true
    # * *Raises* :
    #   -         Ardtweeno::InvalidData or Ardtweeno::ManagerNotDefined if manager is nil
    # 
    def store(data)
      
      if data.class == Ardtweeno::Packet
        if @manager.nil?
          raise Ardtweeno::ManagerNotDefined, "Error the SerialParser is not currently assigned a manager"
        else
          begin
            # Search for the node which corresponds with this key
            node = @manager.search({:key=>data.key})
            
            # Then store the packet in its list
            node.enqueue(data)
          rescue Ardtweeno::NotInNodeList => e
            raise Ardtweeno::NodeNotAuthorised, "Node is not authorised for this network, ignoring"
          end
        end

        # packet should be successfully added to its corresponding node
        return true
      else
        raise Ardtweeno::InvalidData, "Data is invalid, ignoring"
      end
      
    end
    
    
    ##
    # Ardtweeno::SerialParser#write initiates the conversion of an Ardtweeno::Packet to JSON
    # before writing to a SerialPort device
    #
    # * *Args*    :
    #   - ++ ->   Ardtweeno::Packet
    # * *Returns* :
    #   -         true || false
    # * *Raises* :
    #   -         
    # 
    def write(data)
      @log.debug "Validating data"
      if SerialParser.valid_json?(data)
        @log.debug "Data validated"
        @sp.write(data)
        return true
      else
        @log.debug "Data is invalid"
        return false
      end
    end
    
    
    ##
    # Ardtweeno::SerialParser#valid_json? validates JSON data
    #
    # * *Args*    :
    #   - ++ ->   JSON String
    # * *Returns* :
    #   -         true || false
    # * *Raises* :
    #   -         
    # 
    def self.valid_json?(json_)
      begin
        JSON.parse(json_)
        return true
      rescue Exception => e
        return false
      end
    end
    
    
    
    ##
    # Ardtweeno::SerialParser#nextSeq returns the next available sequence number
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Fixnum
    # * *Raises* :
    #   -         
    # 
    def nextSeq()
      @log.debug "Current Sequence Number: " + @seqNo.to_s    
      theSeq = @seqNo
      @seqNo += 1
      @log.debug "Current Sequence Number Incremented: " + @seqNo.to_s
      
      return theSeq
    end
    
    
    ##
    # Ardtweeno::SerialParser#close Closes the SerialPort instance
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    # 
    def close()
      @log.debug "Closing SerialPort device"
      @sp.close
    end
    
  end
end



