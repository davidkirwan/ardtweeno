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
require "rubygems"
require "serialport"
require "logger"

class SerialDeviceMock
  
  attr_accessor :sp, :log
  
  def initialize(dev, speed, timeout, options={})
    @log = options[:log] ||= Logger.new(STDOUT)
    @log.level = options[:level] ||= Logger::DEBUG
    
    @log.debug "Creating instance of SerialDeviceMock"
    
    @sp = SerialPort.new(dev, speed)
    @sp.read_timeout = timeout
  end
   
  def write(val)
    @log.debug "Writing #{val} to the serial device"
    @sp.write(val)
  end
  
  def read()
    data = @sp.read()
    @log.debug "The following was read from the device #{data}"
    return data
  end
  
  def close
    @log.debug "Closing SerialPortMock device"
    @sp.close
  end
  
end
