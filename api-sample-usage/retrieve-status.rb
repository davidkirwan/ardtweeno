####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample Script for retrieving the gateway status
#
# @date         2013-08-21
####################################################################################################

require 'typhoeus'
require 'json' 

puts "This script will query the gateway and retrieve the status and system load."

response = Typhoeus::Request.get("http://localhost:4567/api/v1/system/status")
parsedResponse = JSON.parse(response.body)

puts "\nSystem SerialParser subsystem running: " + parsedResponse["running"].to_s
puts "System CPU Load: #{parsedResponse["cpuload"]}%"
puts "System MEM Usage: #{parsedResponse["memload"]}%\n\n"
puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"
