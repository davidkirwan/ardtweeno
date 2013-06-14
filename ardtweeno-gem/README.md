# Ardtweeno
Ardtweeno is a distributed sensor mesh network gateway which bridges devices connected through a serial
link to those on the internet over IP. The system is modular in nature with the interface to the 
gateway from the serial link being accessible through a HTTP REST API. This allows many different devices 
potentially at multiple sites to communicate with the central gateway over the internet or to a serial 
device connected locally as would be the case with a directly connected XBee Coordinator.

All data is logged to a local database to allow statistical analysis and graphs to be generated for 
inclusion in hourly/daily reports which can be attached to the systems twitter feed.

The core system is wrapped in a Ruby Sinatra webapp which exposes a HTTP REST API and allows interaction 
with the gateway over RESTful HTTP calls on the IP network. This has been designed with a Raspberry Pi in 
mind and has been tested to work correctly on the Raspbian distribution.

In future releases, I hope to make the service interactable so that it may respond to commands received 
on twitter, or through web hooks and possibly an IRC bot. I plan to develop a fully featured Ruby
on Rails web application to act as an end user front end to the system and display generated reports and
graphs from data recieved on the mesh network, while also extending the feature set of the HTTP REST API
and eventually offer the means to manage and upload updated firmwares to the mesh network nodes.

This is a work in progress! The Wiki associated now contains the instructions for accessing the REST
API and installation instructions. Any bugs encountered can be raised on the issue tracker.

If you would like to collaborate with me on this project please fork the repository and send any changes
through a pull request! I gladly welcome constructive input!



# COPYING / Licence
This software is released under the Creative Commons Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0)
for more information see the full details of this licence here: http://creativecommons.org/licenses/by-nc/3.0/

For information regarding commercial use of the Ardtweeno Gateway, please contact the author at:
davidkirwanirl (_at_) gmail dot com or through Twitter at @kirwan\_david


# DISCLAIMER
All code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
