####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  API Sample script to retrieve the last 5 packets from the gateway
#
# @date         2013-07-31
####################################################################################################

require 'typhoeus'
require 'json' 


def lastfivepackets(gateway, port, key)
  
  response = retrievepackets(gateway, port, {:body=>{:key => key}})
  
  total = response["total"].to_i
  unless total < 5
    # Determine the offset
    offset = total - 5
    body = {:key => key, :offset=>offset}
    
    response = retrievepackets(gateway, port, {:body=>body})
  end
  
  return response["packets"].reverse
end



def retrievepackets(gateway, port, options={})
  response = Typhoeus::Request.get("http://#{gateway}:#{port}/api/v1/packets", 
                                   :body=> options[:body])

  return JSON.parse(response.body)
end


########################################################################################################

puts "This script will query the gateway and retrieve the last 5 packets of data which were received.\n\n"

thepackets = lastfivepackets("localhost", "4567", "1230aea77d7bd38898fec74a75a87738dea9f657")

thepackets.each do |i|
  puts i.inspect
end
