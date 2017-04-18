=begin
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Gateway
#
# @date         2017-04-18
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
      def save(old_data, new_data, path, options={})
        @log = options[:log] ||= Logger.new(STDOUT)
        @log.level = options[:level] ||= Logger::DEBUG

        begin
	  validated_data = validate_data(new_data)
	  @log.debug "data validated"
          @data = old_data
	  @data["speed"] = validated_data["speed"]
	  @data["dev"] = validated_data["device"]
	  @data["zones"] = validated_data["zones"]
	  @data["nodes"] = validated_data["nodes"]

          unless options[:mode] == 'append'
            f = File.open(path, "w")
          else
            f = File.open(path, "a")
          end
          
	  @log.debug "Writing data to file"
          f.write(@data.to_yaml)
          f.close
        rescue Exception => e
	  raise e
        end
        return @data
      end


      # Validate the data before saving it
      def validate_data(new_data)
	speed = new_data["speed"]
	@log.debug speed
	@log.debug "Verifying serial device speed"
        raise Ardtweeno::InvalidSerialSpeedException, "Invalid serial device speed specified" unless ["1200", "2400", "4800", "9600", "19200", "38400", "57600", "115200"].include?(speed)
	device = new_data["device"]
	@log.debug "Verifying existance of serial device"
	raise Ardtweeno::InvalidSerialDeviceException, "Invalid device" unless File.exists?(device)

	begin
	  @log.debug "Verifying structure of the Zone JSON configuration"
	  zones = JSON.parse(new_data["config"])
	  @log.debug zones.class
	  @log.debug zones.inspect
	  raise Exception unless zones.class == Array
	  zones.map {|i| raise Exception unless i.class == Hash && i.key?("zonename") && i.key?("zonekey") && i.key?("zonenodes")}
	rescue Exception => e
	  raise Ardtweeno::MalformedZoneJSONException, "Zones json malformed" unless false
	end

	begin
	  @log.debug "Verifying structure of the Node JSON configuration"
          nodes = JSON.parse(new_data["nconfig"])
	  @log.debug nodes.class
	  @log.debug nodes.inspect
	  raise Exception unless nodes.class == Array
	  nodes.map {|i| raise Exception unless i.class == Hash && i.key?("name") && i.key?("key") && i.key?("sensors")}
	rescue Exception => e
	  raise Ardtweeno::MalformedNodeJSONException, "Nodes json malformed" unless false
	end
	{"speed"=>speed,"device"=>device,"zones"=>zones,"nodes"=>nodes}
      end
      
    
    end
  end

end
