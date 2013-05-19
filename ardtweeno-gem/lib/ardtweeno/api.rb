####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  API class for the Ardtweeno system
#
# @date         21-02-2013
####################################################################################################

# Imports
require 'rubygems'
require 'logger'
require 'yaml'
require 'json'
require 'date'

module Ardtweeno

  class API
    class << self
    
      attr_accessor :log



      ##
      # Ardtweeno::API#retrievezones method to filter node zone according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   
      # * *Returns* :
      #   -
      # * *Raises* :
      #
      def retrievezones(config, params)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        params = params.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
        
        zones = Array.new
        
        config["zones"].each do |i|
          data = {:zonename=>i["zonename"], :key=> i["zonekey"], :nodes=>i["zonenodes"]}
            
          zones << data 
        end
        
        if params.has_key?(:zonename)
          zones = handleZoneName(zones, params)
        end
        
        @log.debug "Performing pagination functions on zone list"
        params.delete(:seqno) # Zones don't have seqno's
        zones = handlePagination(zones, params) # Perform pagination operations on results
        
        
        final = {:zones=>zones, :total=>config["zones"].size, :found=>zones.size}
        
        return final # Return the final results
      end



      ##
      # Ardtweeno::API#retrievenodes method to filter node data according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   
      # * *Returns* :
      #   -
      # * *Raises* :
      #
      def retrievenodes(nodeList, params)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        params = params.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
        
        nodes = Array.new
        
        nodeList.each do |i|
          
          data = {:name=>i.node, :key=> i.key, :description=>i.description, 
                  :version=>i.version, :sensors=>i.sensors, 
                  :packets=>i.packetqueue.size}
            
          nodes << data 
        end
        
        
        if params.has_key?(:name)
          nodes = handleName(nodes, params)
        end
        
        if params.has_key?(:nodekey)
          nodes = handleNodeKey(nodes, params)
        end
        
        if params.has_key?(:version)
          nodes = handleVersion(nodes, params)
        end
        
         
        @log.debug "Performing pagination functions on node list"
        params.delete(:seqno) # Nodes don't have seqno's
        nodes = handlePagination(nodes, params) # Perform pagination operations on results
        
        
        final = {:nodes=>nodes, :total=>nodeList.size, :found=>nodes.size}
        
        return final # Return the final results
      end
      


      ##
      # Ardtweeno::API#retrievepackets method to filter packet data according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   
      # * *Returns* :
      #   -
      # * *Raises* :
      #
      def retrievepackets(nodeList, params)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        params = params.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
        
        packetqueue = Array.new
      
        if params.has_key?(:node)
          @log.debug "the params has a node key"
          nodeList.each do |i|
            @log.debug "Matching #{i.node} with #{params[:node]}"
            if i.node == params[:node]
              @log.debug params
              @log.debug i.node            
              packetqueue = i.packetqueue # Found the node we are interested in,
                                          # extract the packets                        
              break # Node found break and continue
            end
          end
        else # Aggregate all

          @log.debug "the params does not have a node key"
          nodeList.each do |i|
            packetqueue += i.packetqueue
            packetqueue = packetqueue.sort_by {|x| x.seqNo} # Not exactly ideal.. but it works ;p
          end
        end
        
        # From most specific to least specific
        
        if params.has_key?(:seqno)
          packetqueue = handleSeqNo(packetqueue, params)
        end
        
        if params.has_key?(:minute)
          packetqueue = handleMinute(packetqueue, params)
        end
 
        if params.has_key?(:hour)
          packetqueue = handleHour(packetqueue, params)
        end
                      
        if params.has_key?(:date)
          packetqueue = handleDate(packetqueue, params)
        end


        packets = handlePagination(packetqueue, params) # Perform pagination operations on results
        
        final = {:packets=>packets, :total=>packetqueue.size, :found=>packets.size}
        
        return final # Return the final results
      end

      

      ##
      # Ardtweeno::API#handleZoneName method to filter according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   Array nodes, Hash params
      # * *Returns* :
      #   -         Array
      # * *Raises* :
      #      
      def handleZoneName(theArray, theParams)
        @log.debug "handleZoneName function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the node required
          if i[:zonename] == theParams[:zonename]
            containerArray << i
          end
        end
        
        if containerArray.size == 0
          @log.debug "version not found, returning empty array"
        end
        
        return containerArray  
      end



      ##
      # Ardtweeno::API#handleVersion method to filter according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   Array nodes, Hash params
      # * *Returns* :
      #   -         Array
      # * *Raises* :
      #      
      def handleVersion(theArray, theParams)
        @log.debug "handleVersion function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the node required
          if i[:version] == theParams[:version]
            containerArray << i
          end
        end
        
        if containerArray.size == 0
          @log.debug "version not found, returning empty array"
        end
        
        return containerArray  
      end
      
      
            
      ##
      # Ardtweeno::API#handleNodeKey method to filter packet data according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   Array nodes, Hash params
      # * *Returns* :
      #   -         Array
      # * *Raises* :
      #      
      def handleNodeKey(theArray, theParams)
        @log.debug "handleNodeKey function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the node required
          if i[:key] == theParams[:nodekey]
            containerArray << i
            return containerArray
          end
        end
        
        @log.debug "key not found, returning empty array"
        return containerArray  
      end
      
      
            
      ##
      # Ardtweeno::API#handleName method to filter packet data according to REST API request
      #
      # * *Args*    :
      #   - ++ ->   Array nodes, Hash params
      # * *Returns* :
      #   -         Array
      # * *Raises* :
      #      
      def handleName(theArray, theParams)
        @log.debug "handleName function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the node required
          if i[:name] == theParams[:name]
            containerArray << i
            return containerArray
          end
        end
        
        @log.debug "name not found, returning empty array"
        return containerArray  
      end


      
      ##
      # Ardtweeno::API#handleSeqNo method to filter packet data according to 
      # meet the REST API seqNo request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #      
      def handleSeqNo(theArray, theParams)
        @log.debug "handleSeqNo function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the packet required
          if i.seqNo == theParams[:seqno].to_i
            containerArray << i
            return containerArray
          end
        end
        
        @log.debug "seqNo not found, returning empty array"
        return containerArray
      end
      
      
      ##
      # Ardtweeno::API#handleHour method to filter packet data according to 
      # meet the REST API seqNo request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #      
      def handleHour(theArray, theParams)
        @log.debug "handleHour function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the packet required
          if i.hour == theParams[:hour]
            containerArray << i
          end
        end
        
        @log.debug "Returning Packet data after Hour filtering"
        return containerArray
      end
      
      ##
      # Ardtweeno::API#handleMinute method to filter packet data according to 
      # meet the REST API seqNo request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #      
      def handleMinute(theArray, theParams)
        @log.debug "handleHour function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the packet required
          if i.minute == theParams[:minute]
            containerArray << i
          end
        end
        
        @log.debug "Returning Packet data after Minute filtering"
        return containerArray
      end
          
      
      ##
      # Ardtweeno::API#handleDate method to filter packet data according to 
      # meet the REST API date request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #      
      def handleDate(theArray, theParams)
        @log.debug "handleDate function called"
        
        containerArray = Array.new
        
        theArray.each do |i|
          # Found the packet required
          if i.date == theParams[:date]
            containerArray << i
          end
        end
        
        @log.debug "Returning Packet data after Date filtering"
        return containerArray
      end
      
      
      ##
      # Ardtweeno::API#handlePagination method to filter packet data according to 
      # meet the REST API pagination request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #
      def handlePagination(theArray, theParams)
        @log.debug "handlePagination function called"
        
        offsetTransformed = handleOffset(theArray, theParams)
        lengthTransformed = handleLength(offsetTransformed, theParams)
        sortTransformed = handleSort(lengthTransformed, theParams)
        
        final = sortTransformed
        
        return final # return the Array modified by pagination requests
      end
      
      
      ##
      # Ardtweeno::API#handleOffset method to filter according to 
      # the REST API pagination request
      #
      # * *Args*    :
      #   - ++ ->   Array *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array
      # * *Raises* :
      #
      def handleOffset(theArray, theParams)
        @log.debug "handleOffset function executing"
        
        if theParams.has_key?(:offset)
          @log.debug "params hash contains an offset value of #{theParams[:offset]}"
          modifiedArray = Array.new
          
          if theParams[:offset].to_i == 0 or theParams[:offset].to_i < 0
            @log.debug "Offset value is either equal to 0 or less than 0 returning default array"
            return theArray # Offset value equates to start of array
            
          elsif theParams[:offset].to_i > theArray.size
            @log.debug "Offset value is larger than the size of the available array, returning" + 
                        " empty array"
            return [] # The offset can never be satisfied returning empty array
            
          else
            @log.debug "theArray size: #{theArray.size}"
            ((theParams[:offset].to_i)..(theArray.size - 1)).step(1) do |i|
              modifiedArray << theArray[i]
            end
            return modifiedArray # Returning the transformed array
            
          end
        end
        
        @log.debug "No changes made, returning original array"
        return theArray # No change, returning original array
      end
      
      
      
      ##
      # Ardtweeno::API#handleLength method to filter according to 
      # the REST API pagination request
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet
      # * *Raises* :
      #      
      def handleLength(theArray, theParams)
        @log.debug "handleLength function executing"
        
        modifiedArray = Array.new
        
        if theParams.has_key?(:length) and theParams[:length].to_i < 100
          length = theParams[:length].to_i
          @log.debug "theParams has a length value of #{length}"
        else
          length = 100
          @log.debug "Defaulting to the default length of #{length}"
        end
        
          
        if theArray.size > length
          @log.debug "Length is smaller than the size of theArray"
          (0..(length - 1)).step(1) do |i|
            modifiedArray << theArray[i]
          end
          
          @log.debug "Returning transformed array"
          return modifiedArray # Returning transformed array
        else
          @log.debug "No need to perform any operations, returning original array"
          return theArray # No need to perform any transformation, length pagination request
                          # is larger than the available data, returning original
        end
      end
      
      
      ##
      # Ardtweeno::API#handleSort method to filter according to 
      # the REST API pagination request. 
      #
      # * *Args*    :
      #   - ++ ->   Array of Ardtweeno::Packet *theArray*, Hash of parameters *theParams*
      # * *Returns* :
      #   -         Array of Ardtweeno::Packet sorted by seqNo values either ascending or
      #             decending
      # * *Raises* :
      #      
      def handleSort(theArray, theParams)
        @log.debug "handleSort function executing"
        
        if theParams.has_key?(:sort) and theParams[:sort] == "desc"
          theArray = theArray.sort_by {|x| x.seqNo}
          return theArray.reverse()

        else
          return theArray # Order is already ascending, return original array
        end

      end


      
      
    end
  end # End of API class


# End of Ardtweeno Module
end
