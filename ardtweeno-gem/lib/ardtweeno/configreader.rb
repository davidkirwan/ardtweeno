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

require 'rubygems'
require 'yaml'
require 'fileutils'

module Ardtweeno

  class ConfigReader
    class << self
  
      attr_accessor :data, :log;
      
      # Loads the database from disk
      def load(path, options={})
      @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
      @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        begin
          @data = YAML.load(File.open(path))
          log.debug @data.inspect
          
        rescue ArgumentError => e
          log.fatal "Could not parse YAML: #{e.message}"
          log.fatal e.backtrace
          exit()
        end
        
        return @data  
      end
      
      
      # Saves the database to disk
      def save(newData, path, options={})
        @log = options[:log] ||= Logger.new(STDOUT)
        @log.level = options[:level] ||= Logger::DEBUG

        begin
	  validate_data(newData)
          #@data = newData
        
          #unless options[:mode] == 'append'
          #  f = File.open(path, "w")
          #else
          #  f = File.open(path, "a")
          #end
          
	  @log.debug "Writing data to file"
          #f.write(@data.to_yaml)
          #f.close
        rescue Exception => e
	  raise e
        end
        return @data
      end


      # Validate the data before saving it
      def validate_data(new_data)
        raise Ardtweeno::InvalidSerialSpeedException, "Invalid serial device speed specified" unless ["1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"].include?(new_data["speed"])
	raise Ardtweeno::InvalidSerialDeviceException, "Invalid device" unless File.exists?(new_data["device"]) 
	raise Ardtweeno::MalformedZoneJSONException, "Zones json malformed" unless false
	raise Ardtweeno::MalformedNodeJSONException, "Nodes json malformed" unless false
      end
      
    
    end
  end

end
