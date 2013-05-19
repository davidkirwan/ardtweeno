####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Packet Communication storage class for the Ardtweeno system
#
# @date         14-11-2012
####################################################################################################

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
    attr_accessor :key, :seqNo, :date, :hour, :minute, :node, :data 
    
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
            " " + @hour + ":" + @minute + " Data: " + @data.to_s  
      
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
      @minute.to_s + '","node":"' + @node + '","key":"' + @key + '","seqNo":' +
      @seqNo.to_s + ',"data":' + @data.to_json + '}'
      
      return jsonStr
    end
    
    
  end
end
