require 'typhoeus'
require File.join(File.dirname(__FILE__), '/exceptions.rb')


module Example
class Utility
  class << self
    
    # Retrieve the information for the / route
    def root(uri, port, key)
      response = Hash.new
      
      # Retrieve the data
      theStatus = status(uri, port, key)
      thePackets = lastfivepackets(uri, port, key) 
      theZones = listzones(uri, port, key)

      # Create a response Hash
      response = {:status=>theStatus,
                  :packets=>thePackets,
                  :zones=>theZones}
      
      # Return the response Hash
      return response
    end
    
    
    
    def controlpanel(uri, port, key)
      response = Hash.new
      
      # Retrieve the data
      theNodes = listnodes(uri, port, key)
      
      # Retreive the watchList data
      theWatchList = listwatchednodes(uri, port, key)
      
      # Create the response Hash
      response = {:nodes=>theNodes,
                  :watchList=>theWatchList}
      
      # Return the response Hash
      return response      
    end



    def addwatch(uri, port, key, node)
      body = {:key=>key,
              :notifyURL=>"http://localhost:5000/push/#{node}", 
              :method=>"GET", 
              :timeout=>60}

      response = Typhoeus::Request.post("http://#{uri}:#{port}/api/v1/watch/#{node}", :body=>body)
      if response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
      if response.code == 400
        raise Example::Error500
      elsif response.code == 500
        raise Example::Error500 
      end
      
      return "Yes"
    end
    
    
    
    def listzones(gateway, port, key)
      response = retrievezones(gateway, port, {:body=>{:key => key}})
      
      total = response["total"] 
      unless total > 100
        # The total number of zones exceeds the number which can be retrieved in a single API
        # call, so buffer and retrieve the rest
        
        theZones = response["zones"]
        
        # Set the initial offset to the max 
        offset = 100
        # Set remaining initially to the total
        remaining = total
        
        until remaining < 0
          response = retrievezones(gateway, port, {:body=>{:key=>key, :offset=>offset}})
          offset += 100
          remaining = total - offset
          theZones.concat(response["zones"])
        end
        
        return theZones
      end
      
      return response["zones"]
    end
    
    
    
    def listwatchednodes(gateway, port, key)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/watch", 
            :body=> {:key=>key})
  
      if response.options[:return_code] == :ok
        begin
          response = JSON.parse(response.body)
          
          watchList = Array.new
          
          response["watched"].each do |i|
            watchList << i["node"]
          end
            
          return watchList
          
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
    
    
    def listnodes(gateway, port, key)
      response = retrievenodes(gateway, port, {:body=>{:key => key}})
      
      total = response["total"] 
      unless total > 100
        # The total number of nodes exceeds the number which can be retrieved in a single API
        # call, so buffer and retrieve the rest
        
        theNodes = response["nodes"]
        
        # Set the initial offset to the max 
        offset = 100
        # Set remaining initially to the total
        remaining = total
        
        until remaining < 0
          response = retrievenodes(gateway, port, {:body=>{:key=>key, :offset=>offset}})
          offset += 100
          remaining = total - offset
          theNodes.concat(response["nodes"])
        end
        
        return theNodes
      end
      
      return response["nodes"]
    end
    
    
    
    def lastfivepackets(gateway, port, key)
      
      response = retrievepackets(gateway, port, {:body=>{:key => key}})
      
      total = response["total"] 
      unless total < 5
        # Determine the offset
        offset = total - 5
        body = {:key => key, :offset=>offset}
        
        response = retrievepackets(gateway, port, {:body=>body})
      end
      
      return response["packets"].reverse
    end
    
    
    
    def status(gateway, port, key)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/status", 
            :body=> {:key=>key})
  
      if response.options[:return_code] == :ok
        begin
          response = JSON.parse(response.body)
            
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
    
    
    def gatewaystart(gateway, port, key)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/start", 
          :body=> {:key=>key})

      if response.options[:return_code] == :ok
        begin
          response = response.body
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end



    def gatewaystop(gateway, port, key)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/stop", 
          :body=> {:key=>key})

      if response.options[:return_code] == :ok
        begin
          response = response.body
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end  
    
    

    def gatewayconfig(gateway, port, key)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/config", 
          :body=> {:key=>key})

      if response.options[:return_code] == :ok
        begin
          response = JSON.pretty_generate(JSON.parse(response.body))
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
    
    
    def retrievezones(gateway, port, options={})
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/zones", 
            :body=> options[:body])
  
      if response.options[:return_code] == :ok
        begin
          response = JSON.parse(response.body)
            
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
    
    
    def retrievenodes(gateway, port, options={})
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/nodes", 
            :body=> options[:body])
  
      if response.options[:return_code] == :ok
        begin
          response = JSON.parse(response.body)
            
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
    
    
    def retrievepackets(gateway, port, options={})
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/packets", 
            :body=> options[:body])
  
      if response.options[:return_code] == :ok
        begin
          response = JSON.parse(response.body)
            
        rescue Exception => e
          raise Example::Error500
        end
      elsif response.options[:return_code] == :couldnt_connect
        raise Example::Error503
      end
    end
    
  
  
  end
end
end
