####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample script to post packets of data to the gateway with a random sleep between 
#               posts
#
# @date         2013-07-31
####################################################################################################

require 'typhoeus'
require 'json' 

puts "This script will post a packet to the gateway for node0 and node1 every 10 - 90 seconds in a loop.\n" +
     "To quit press ^C ctrl-C"

key = "1230aea77d7bd38898fec74a75a87738dea9f657"
testData = {"data" => [rand(0..100)], "key" => "2dbf44a68b77b15bfa5bc3d66c97892a57402bbe"}.to_json
testData2 = {"data" => [rand(0..100), rand(0..1000)], "key" => "a46fe0c4dab0453f5d86bed6206040880f59393e"}.to_json
  
while true
  response = Typhoeus::Request.post("http://localhost:4567/api/v1/packets", :body=> {:key => key, :payload=>testData})
  puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"
  sleep(rand(10..90))
  response = Typhoeus::Request.post("http://localhost:4567/api/v1/packets", :body=> {:key => key, :payload=>testData2})
  puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"
  sleep(rand(10..90))
end
