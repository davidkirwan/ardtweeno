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
