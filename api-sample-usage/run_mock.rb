####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample script for emulating the XBee device connected to a tty. This works well
#               with the tty0tty null modem emulator. Connect the gateway to the other end of this 
#               tty0tty pseudo tty. 
#
# @date         2013-07-31
####################################################################################################

require 'serialport'
require 'json'
require "../ardtweeno-gem/test/serialport_mock.rb"

mock = SerialDeviceMock.new('/dev/pts/3', 9600, 100)
  
while true
  testData = {"data" => [rand(0..100), rand(700..1100), rand(0..500)], "key" => "500d81aafe637717a52f8650e54206e64da33d27" }.to_json
  testData2 = {"data" => [rand(0..100), rand(700..1100), rand(0..500)], "key" => "f937c37e949d9efa20d2958af309235c73ec039a" }.to_json
  mock.write(testData)
  mock.read()
  sleep(5)  
  mock.write(testData2)
  mock.read()
  sleep(5)
end
