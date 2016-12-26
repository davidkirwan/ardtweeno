####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample script to post packets of data to the gateway with a random sleep between 
#               posts
#
# @date         2014-08-06
####################################################################################################

require 'typhoeus'
require 'json' 

puts "This script will post a packet to the gateway for node0 and node1 every 10 - 90 seconds in a loop.\n" +
     "To quit press ^C ctrl-C"

key = "1230aea77d7bd38898fec74a75a87738dea9f657"
no_of_sensors = 1

while true
  data = Array.new
  1.upto(no_of_sensors) do data << rand(0..100); end

  testData = {"data" => data, "key" => "500d81aafe637717a52f8650e54206e64da33d27"}.to_json

  response = Typhoeus::Request.post("http://localhost:4567/api/v1/packets", :body=> {:key => key, :payload=>testData})
  puts "API HTTP Code: [" + response.code.to_s + "] API Response: [" + response.options[:return_code].to_s + "]"

  sleep(rand(0.5..2))
end
