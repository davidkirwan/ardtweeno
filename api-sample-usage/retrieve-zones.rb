####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample Script for retrieving the zones associated with the gateway
#
# @date         2013-08-21
####################################################################################################

require 'rubygems'
require 'typhoeus'
require 'json'

apikey = '1230aea77d7bd38898fec74a75a87738dea9f657'
paramsToSend = {:key => apikey}

zones = Typhoeus::Request.get("http://localhost:4567/api/v1/zones", 
:body=> paramsToSend).body

parsedZones = JSON.parse(zones)
puts JSON.pretty_generate(parsedZones)

puts "This script will query the gateway and retrieve the zones associated with the gateway."
 