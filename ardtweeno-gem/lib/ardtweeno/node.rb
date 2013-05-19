####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Class to model an Ardtweeno Mesh Network Node
#
# @date         21-02-2013
####################################################################################################
# Imports
require 'rubygems'
require 'logger'
require 'yaml'
require 'json'
require 'ardtweeno'

module Ardtweeno
  
  ##
  # Ardtweeno::Node class to model an Ardtweeno mesh network node
  #
  # Example YAML representation of an Ardtweeno::Node
  #- 
  #  name: node0
  #  key: 500d81aafe637717a52f8650e54206e64da33d27
  #  description: This node is outside
  #  version: 0.0.3
  #  sensors:
  #    - Temperature
  #    - Barometric Pressure
  #    - Altitude
  class Node
    
    attr_accessor :node, :key, :description, :version, :sensors, :log, :packetqueue
    
    
    ##
    # Ardtweeno::Node#new Constructor
    #
    # * *Args*    :
    #   - ++ -> newNode String, newKey String, options Hash{:description String, 
    # :version String, :sensors Array}
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def initialize(newNode, newKey, options={})
      @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
      @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
      
      @node = newNode
      @key = newKey
      
      @description = options[:description] ||= "Default Description"
      @version = options[:version] ||= Ardtweeno::VERSION
      @sensors = options[:sensors] ||= Array.new
      
      @packetqueue = Array.new
      
    end
    
    
    
    ##
    # Ardtweeno::Node#enqueue stores an Ardtweeno::Packet in the maintained packet list
    #
    # * *Args*    :
    #   - ++ ->   Ardtweeno::Packet
    # * *Returns* :
    #   -         true
    # * *Raises* :
    #   -         Ardtweeno::NotAPacket
    def enqueue(packet)
      
      if packet.class == Ardtweeno::Packet
        packet.node = @node
        @packetqueue << packet
        return true
      else
        raise Ardtweeno::NotAPacket
      end
      
    end
    
    
    ##
    # Ardtweeno::Node#dequeue stores an Ardtweeno::Packet in the maintained packet list
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Ardtweeno::Packet
    # * *Raises* :
    #   -         Ardtweeno::PacketListEmpty
    def dequeue()
      
      if @packetqueue.empty?
        raise Ardtweeno::PacketListEmpty
      else
        return @packetqueue.delete(@packetqueue.first)
      end
      
    end
    
    
    ##
    # Ardtweeno::Node#to_s converts a Node instance to String
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         String
    # * *Raises* :
    #
    def to_s
      return @node + ", " + @key + ", " + @description + ", " + @version + ", " + @sensors.to_s, @packetqueue.to_s
    end
    
  end
end
