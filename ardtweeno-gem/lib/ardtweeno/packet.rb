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


module Ardtweeno
  
  ##
  # Ardtweeno::Packet Communication storage class for the Ardtweeno system
  #
  class Packet
    
    # Class fields
    attr_accessor :key, :seqNo, :date, :hour, :minute, :second, :node, :data 
    
    ##
    # Ardtweeno::Packet#new for the Packet class
    # * *Args*    :
    #   - ++ -> :seqNo, :key, :data  
    # * *Returns* :
    #   -
    # * *Raises* :
    #
    def initialize(newSeqNo, newKey, newData)
      
      # Create a DateTime instance
      today = DateTime.now
      theDate = today.year.to_s() + "-" + "%02d" % today.month.to_s() + "-" + "%02d" % today.day.to_s()
      
      # Default values
      @date = theDate
      @hour = ("%02d" % today.hour).to_s
      @minute = ("%02d" % today.min).to_s
      @second = ("%02d" % today.sec).to_s
      @data = newData
      @key = newKey
      
      # Need to implement a lookup function for key to node value
      @node = "defaultNode"
      
      if newSeqNo.class == Fixnum
        @seqNo = newSeqNo
      elsif newSeqNo.class == String
        @seqNo = newSeqNo.to_i
      end
      
    end

    
    ##
    # Ardtweeno::Packet#to_s returns a representation of the current instance state in String form
    #
    # * *Args*    :
    #   - ++ ->  
    # * *Returns* :
    #   -         String
    # * *Raises* :
    #    
    def to_s
      # Build the string up from field data
      str = "Packet No: " + @seqNo.to_s + " Key: " + @key + " Node: " + @node + " Date: " + @date +
            " " + @hour + ":" + @minute + ":" + @second + " Data: " + @data.to_s  
      
      # Returns the built string
      return str
    end
    

    ##
    # Ardtweeno::Packet#to_json returns a representation of the current instance state in JSON form
    #
    # * *Args*    :
    #   - ++ ->  
    # * *Returns* :
    #   -         String
    # * *Raises* :
    #    
    def to_json(options={})
      
      jsonStr = '{"date":"' + @date + '","hour":"' + @hour + '","minute":"' +
      @minute + '","second":"' + @second + '","node":"' + @node + '","key":"' + @key + '","seqNo":' +
      @seqNo.to_s + ',"data":' + @data.to_json + '}'
      
      return jsonStr
    end
    
    
  end
end
