####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample Script for retrieving the nodes associated with the gateway
#
# @date         2013-08-21
####################################################################################################

require 'rubygems'
require 'typhoeus'
require 'json'

apikey = '1230aea77d7bd38898fec74a75a87738dea9f657'
paramsToSend = {:key => apikey}

nodes = Typhoeus::Request.get("http://localhost:4567/api/v1/nodes", 
:body=> paramsToSend).body

parsedNodes = JSON.parse(nodes)
puts JSON.pretty_generate(parsedNodes)

puts "This script will query the gateway and retrieve the nodes associated with the gateway."
 