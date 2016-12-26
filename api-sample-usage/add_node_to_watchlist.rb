####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample Script for adding a node to the watchlist
#
# @date         2013-07-31
####################################################################################################

require 'typhoeus'
require 'json' 


body = {:key=> "1230aea77d7bd38898fec74a75a87738dea9f657", 
		:notifyURL=>"http://localhost:5000/push/node1", 
		:method=>"GET", 
		:timeout=>60}


puts "This script adds the node1 to a watchlist. When packets are received from node1, the gateway will send\n" +
     "a push notification to the URL mentioned in the :notifyURL key. The :method can be GET or POST, these\n" + 
     "refer to the HTTP requests which the system being notified expects. The :timeout indicates the minimum\n" +
     "timeout between push notifications.\n\n"

response = Typhoeus::Request.post("http://localhost:4567/api/v1/watch/node1", :body=>body)

puts "Parameters: [" + body.inspect + "]"
puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"
