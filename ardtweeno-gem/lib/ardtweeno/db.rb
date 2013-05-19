####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  API class for the Ardtweeno system
#
# @date         08-01-2013
####################################################################################################

# Imports
require 'rubygems'
require 'logger'
require 'yaml'
require 'json'
require 'date'
require 'mongo'


module Ardtweeno

  ##
  # Ardtweeno::DB class to handle communication with a MongoDB Database
  #
  class DB
    class << self
    
      attr_accessor :log, :dbconnector, :auth, :coll
      
      ##
      # Ardtweeno::DB#new Constructor
      #
      # * *Args*    :
      #   - ++ -> newNode String, newKey String, options Hash{:description String, 
      # :version String, :sensors Array}
      # * *Returns* :
      #   -
      # * *Raises* :
      #
      def initialize
        @log = Ardtweeno.options[:log] ||= Logger.new(STDOUT)
        @log.level = Ardtweeno.options[:level] ||= Logger::DEBUG
        
        @dbconnector = Mongo::Connection.new(host, port).db(databaseName)
        @auth = @dbconnector.authenticate(my_user_name, my_password)
        @coll = @dbconnector.collection(collName)
        
        
      end
      
    
    end
  end
end
