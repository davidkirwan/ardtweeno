####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Settings Helper Class for the Ardtweeno Sample Demo
#
# @date         26-06-2013
####################################################################################################

require 'logger'
require 'yaml'

module SampleDemo

  class ConfigReader
    class << self
  
      attr_accessor :data, :log;
      
      # Loads the database from disk
      def load(path, options={})
      @log = options[:log] ||= Logger.new(STDOUT)
      @log.level = options[:level] ||= Logger::DEBUG
        
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
