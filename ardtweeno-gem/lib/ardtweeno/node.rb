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
