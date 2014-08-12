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
require 'serialport'
require 'logger'
require 'yaml'
require 'json'
require 'typhoeus'

module Ardtweeno
  
  ##
  # Ardtweeno::SerialParser class for the Ardtweeno system
  #
  class SerialParser
    
    attr_accessor :sp, :log, :testing
    
    ##
    # Ardtweeno::SerialParser#new constructor for the Ardtweeno system
    #
    # * *Args*    :
    #   - ++ ->   dev String, speed Fixnum, timeout Fixnum, {:log}
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    # 
    def initialize(dev, speed, timeout, options={})
      @log = options[:log] ||= Logger.new(STDOUT)
      @log.level = options[:level] ||= Logger::WARN
      @testing = options[:testing] ||= false
      
      if @testing
        @log.debug "Creating instance of Ardtweeno::SerialParser for testing"
      else
        @log.debug "Creating instance of Ardtweeno::SerialParser"
      end
      
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
      return @sp.read
    end
    
    
    
    ##
    # Ardtweeno::SerialParser#listen listens for a packet of data to be received on the serial
    # =>                              device then posts it to the Ardtweeno API
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #   -         
    #     
    def listen(key)      
      data = ""
      1.upto(10) do |i|
        data += read()
        if valid_json?(data)
          @log.debug "Posting to the API"
          @log.debug "#{data}"
          begin
            return postToAPI(data, key)
          rescue Exception => e
            raise e
          end
          break
        end
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
    def valid_json?(json_)
      begin
        JSON.parse(json_)
        return true
      rescue Exception => e
        return false
      end
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
    
    
    
    ##
    # Ardtweeno::SerialParser#postToAPI posts a packet of data to the Ardtweeno gateway
    #
    # * *Args*    :
    #   - ++ ->   JSON String
    # * *Returns* :
    #   -         true || false
    # * *Raises* :
    #   -         
    #
    def postToAPI(data, key)
      body = {:key => key, :payload=>data}
      
      unless @testing        
        begin
          Typhoeus::Request.post("http://localhost:4567/api/v1/packets", :body=> body)
        rescue Exception => e
          raise e
        end
      else
        return body
      end
    end
    
    
    private :postToAPI
    
  end
end



