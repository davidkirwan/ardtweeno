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
        
        @data = newData
        
        begin
          unless options[:mode] == 'append'
            f = File.open(path, "w")
          else
            f = File.open(path, "a")
          end
          
          f.write(@data.to_yaml)
          f.close
        rescue Exception => e
          @log.fatal e.message
          @log.fatal e.backtrace
          exit()
        end
        
      end      
      
    
    end
  end

end
