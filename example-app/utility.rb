require 'typhoeus'
require File.join(File.dirname(__FILE__), '/exceptions.rb')


module Example
class Utility
  class << self
  
    def root(key, uri, port)
      response = Hash.new
      
      theStatus = status(key, uri, port)
      
      response = {:status=>theStatus}
      
      return response
    end
    
    
    
    def status(key, gateway, port)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/status", 
            :body=> {:key => key})
  
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
    
    
    
    def gatewaystart(key, gateway, port)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/start", 
          :body=> {:key => key})

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



    def gatewaystop(key, gateway, port)
      response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/system/stop", 
          :body=> {:key => key})

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
  
  
  
  end
end
end