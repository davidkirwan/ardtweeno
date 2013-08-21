####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample Script for retreiving the gateway status
#
# @date         2013-08-21
####################################################################################################

require 'typhoeus'
require 'json' 


puts ""

response = Typhoeus::Request.get("http://localhost:4567/api/v1/system/status")

puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"
