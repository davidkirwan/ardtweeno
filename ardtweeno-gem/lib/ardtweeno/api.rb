####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API class for the Ardtweeno system
#
# @date         2013-08-05
####################################################################################################

# Imports
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


      
      ##
      # Ardtweeno::API#parseTopology method to construct the topology Hash used in API#buildTopology
      #
      # * *Args*    :
      #   - ++ ->   Hash zones containing raw data from API#retrievezones, 
      #             Hash nodes containing raw data from API#retrievenodes
      # * *Returns* :
      #   -         
      # * *Raises* :
      #
      def parseTopology(zones, nodes)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        zonelist = Array.new
        
        begin      
          
          zones[:zones].each do |i|
            zonename = i[:zonename]
            nodelist = Array.new
            
            i[:nodes].each do |j|
              nodename = j
              sensorlist = Array.new
              
              nodes[:nodes].each do |k|
                if nodename == k[:name]
                  sensorlist = k[:sensors]
                end
              end
              
              nodelist << {:name=> nodename, :sensorlist=> sensorlist}
            end
            
            zonelist << {:zonename=>zonename, :nodes=>nodelist}
          end
          
          response = zonelist
          
        rescue Exception => e
          @log.debug e
          return e
        end
        
        @log.debug response.inspect
        return response
        
      end
      
      
      
      ##
      # Ardtweeno::API#buildTopology method for constructing the topology graph
      #
      # * *Args*    :
      #   - ++ ->     Hash containing structured topology data
      # * *Returns* :
      #   -           String containing the Raphael.js code to generate the graph
      # * *Raises* :
      #             
      #
      def buildTopology(topology)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        @log.debug "Number of Zones: #{topology.count.to_s}"
        response = ""           # Will hold our response
        offset = 0              # Offset 
        totalsensorcount = countSensors(topology)    
        @log.debug "Total Sensor Count: " + totalsensorcount.to_s
        
        # Canvas height
        defaultheight = 700
        height = 100 + (totalsensorcount * 100)
        if height <= defaultheight
          height = defaultheight 
          @log.debug "Height less than defaultheight, setting canvas height to 700"
        end
        @log.debug "Canvas height: " + height.to_s
      
        # Set up the Canvas
        response += "var thepaper = new Raphael(document.getElementById('topology-canvas'), " +
                                        "500, #{height});\n"
                                        
        # Draw the graph
        topology.each_with_index do |i, index|
          
          # Initial hookup line
          response += "var hookup1 = thepaper.path('M 50 #{75 + offset} l 50 0');\n"
          
          # Print the Zone name
          response += "var zonetitle = thepaper.text(50, #{20+ offset}, '#{i[:zonename]}').attr({'font-size':20});"
          
          # Print the sensors
          i[:nodes].each_with_index do |j, jndex|
            
            # Print the node
            response += "var node = thepaper.path('M 100 #{100 + offset} " +
                                "l 0 -50 l 50 0 l 0 50 l -50 0').attr(" +
                                "{fill: 'red', 'href':'/graph/v1/punchcard/#{j[:name]}'});\n"
            
            # Print the node name
            response += "var nodetitle = thepaper.text(125, #{40 + offset}, '#{j[:name]}');"
            
            
            # Print the link to next node
            if i[:nodes].count > 1 
              unless (jndex + 1) == i.count
                response += "var nextnode1 = thepaper.path('M 75 #{75 + offset} l 0 " +
                            "#{(j[:sensorlist].count * 100) + 75} l 25 0');"
              end
            end
            
            # Print the sensors
            j[:sensorlist].each_with_index do |k, kndex|
              # Sensor 1 in each node is drawn slightly differently
              if kndex == 0 
                response += "var theline = thepaper.path('M 150 #{75 + offset} l 100 0');\n"
                response += "var thecircle = thepaper.circle(270, #{ 75 + offset}" +
                            ", 20).attr({fill:'green'});\n"
                
                # Print sensortitle
                response += "var sensor1Title = thepaper.text(350, #{75 + offset}, '#{k}');"
                
                offset += 75
              else              
              # Sensors beyond first
                response += "var theline = thepaper.path('M 200 #{offset} l 0 75 l 50 0');"
                response += "var thecircle = thepaper.circle(270, #{ 75 + offset}, 20).attr({fill:'green'});\n"
                
                # Print sensortitle
                response += "var sensor1Title = thepaper.text(350, #{75 + offset}, '#{k}');"
                
                offset += 75
              end
              
            end
            offset += 100
          end
        
        end    
  
        return response
      end
      
      
      ##
      # Ardtweeno::API#countSensors private method for counting the number of sensors in the toplogy
      #
      # * *Args*    :
      #   - ++ ->     Hash containing structured topology data
      # * *Returns* :
      #   -           Fixnum count of the number of sensors in the topology
      # * *Raises* :
      #             
      #
      def countSensors(topology)
        count = 0
        topology.each do |i|
          unless i[:nodes].nil?
            i[:nodes].each do |j|
              unless j[:sensorlist].nil?
                count += j[:sensorlist].count
              end
            end
          end
        end
        return count
      end
      
      
      
      ##
      # Ardtweeno::API#buildPunchcard generate the data used in the Punchcard graph
      #
      # * *Args*    :
      #   - ++ ->     Array of Ardtweeno::Node, Hash params
      # * *Returns* :
      #   -           Array Fixnum, 168 data hourly packet total values for last week,
      #               Array String previous 7 day names 
      # * *Raises* :
      #             
      #
      def buildPunchcard(nodeList, params)
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::WARN
        
        theParams = Hash.new
        theParams[:node] = params[:node]
        
        data = Array.new
        days = Array.new
        
        today = DateTime.now
                
        theStart = today - 6

        theStartDay = "%02d" % theStart.day
        theStartMonth = "%02d" % theStart.month
        theStartYear = theStart.year.to_s
              
        theEndDay = "%02d" % today.day
        theEndMonth = "%02d" % today.month
        theEndYear = today.year.to_s
        
        startRange = theStartYear + "-" + theStartMonth + "-" + theStartDay
        endRange = theEndYear + "-" + theEndMonth + "-" + theEndDay
        
        @log.debug "From #{startRange} to #{endRange}"
        
        
        (theStart..today).each do |i|
          theDay = theStart.strftime('%a')
          days << theDay
          @log.debug theDay
           
          (0..23).each do |j|
            theDate = theStart.year.to_s + "-" + "%02d" % theStart.month + "-" + "%02d" % i.day
            theHour = "%02d" % j
            
            theParams = {:hour=>theHour, :date=>theDate}
            
            nodes = Ardtweeno::API.retrievepackets(nodeList, theParams)
            
            data << nodes[:found].to_i
          end
          
          theStart += 1
        end
        
        @log.debug days.inspect
        
        return data, days.reverse, "#{startRange} to #{endRange}"
      end
      
      
      
      private :countSensors
      
    end
  end # End of API class
end # End of Ardtweeno Module
