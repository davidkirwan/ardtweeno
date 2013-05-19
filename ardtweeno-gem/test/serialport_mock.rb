####################################################################################################
# @author       David Kirwan <davidkirwanirl@gmail.com>
# @description  Mock for a serial port
#
# @date         15-10-2012
####################################################################################################

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
    @log.debug "Closing SerialPort device"
    @sp.close
  end
  
end
