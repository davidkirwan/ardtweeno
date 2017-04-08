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

require 'logger'
require 'fileutils'
require 'pry'
require 'ardtweeno/serialparser'
require 'ardtweeno/dispatcher'
require 'ardtweeno/exceptions'
require 'ardtweeno/packet'
require 'ardtweeno/nodemanager'
require 'ardtweeno/node'
require 'ardtweeno/configreader'
require 'ardtweeno/api'
require 'ardtweeno/db'
require 'ardtweeno/ringbuffer'


##
# Ardtweeno Mesh Network Application Gateway
# 
# Software Gateway to allow collecting/broadcasting to/from a Mesh Network over serial. All data is 
# stored to a database by default to allow later analysis and inclusion in automated reports 
# generated by the system. 
#  
module Ardtweeno
  class << self
    
    
    # Constants
    Ardtweeno::VERSION = "0.5.0" unless defined? Ardtweeno::VERSION
    Ardtweeno::CONFIGPATH = ENV['HOME'] + "/.ardtweeno" unless defined? Ardtweeno::CONFIGPATH
    Ardtweeno::DBPATH = Ardtweeno::CONFIGPATH + "/conf.yaml" unless defined? Ardtweeno::DBPATH
    Ardtweeno::NODEPATH = Ardtweeno::CONFIGPATH + "/nodelist.yaml" unless defined? Ardtweeno::NODEPATH
        
    # Class Variables
    @@seqCount = 0 unless defined? @@seqCount
    @@options = {} unless defined? @@options    
    
    
    ##
    # Ardtweeno#options returns the options hash
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Hash
    # * *Raises* :
    #   -         
    # 
    def options()
      return @@options
    end
    
    
    ##
    # Ardtweeno#nextSeq returns the next available sequence number
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Fixnum
    # * *Raises* :
    #   -         
    # 
    def nextSeq()
      @log = @@options[:log] ||= Logger.new(STDOUT)
      @log.level = @@options[:level] ||= Logger::DEBUG     
      
      @log.debug "Current Sequence Number: " + @@seqCount.to_s    
      theSeq = @@seqCount
      @@seqCount += 1
      @log.debug "Current Sequence Number Incremented: " + @@seqCount.to_s
      
      return theSeq
    end
    
    
    # Setup the system for the first time
    def setup(theoptions={})
      @@options = theoptions
      
      @log = @@options[:log] ||= Logger.new(STDOUT)
      @log.level = @@options[:level] ||= Logger::DEBUG
      
      if @@options[:test]
        @log.debug "Ardtweeno is running test mode"
      end    
      
      @log.debug "Checking to see if the configuration folder exists."
      resourceDir = Ardtweeno::CONFIGPATH
      @log.debug resourceDir
      
      if File.directory?(resourceDir) 
        @log.debug "The folder already exists, do nothing."
      else
        @log.debug "Creating ~/.ardtweeno/ and installing the resources there."
        
        begin
          FileUtils.mkdir(resourceDir)
          dbpath = File.expand_path(File.dirname(__FILE__) + '/../resources/conf.yaml')
          nodepath = File.expand_path(File.dirname(__FILE__) + '/../resources/nodelist.yaml')
          FileUtils.cp(dbpath, resourceDir)
          FileUtils.cp(nodepath, resourceDir)
          @log.debug "Successfully copied ~/.ardtweeno/conf.yaml"
          @log.debug "Successfully copied ~/.ardtweeno/nodelist.yaml"
        rescue Exception => e
          @log.fatal e.message
          @log.fatal e.backtrace
          exit()
        end
      end
      
    end
    
    
  end
end


