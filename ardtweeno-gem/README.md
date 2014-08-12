# Ardtweeno
Ardtweeno is an application gateway which bridges a Serial Device and an Internet Protocol network. 
The system is designed as a PaaS (platform as a service) for the Raspberry Pi ARM platform. All data 
received on the serial interface is stored to a MongoDB database if one is available otherwise stores 
the data in system RAM. The gateway exposes a HTTP REST API for configuration and data manipulation purposes 
which can be queried in order to build statistics, graphs and other forms of data reporting.

The core system is wrapped in a Ruby Sinatra web application which exposes a HTTP REST API and allows interaction 
with the gateway over RESTful HTTP calls on the IP network. This has been designed with a Raspberry Pi in 
mind and has been tested to work correctly on the Raspbian Wheezy distribution.

The system has been designed to be as modular in nature as possible. It is for this reason the interface to 
the gateway from the serial link is through a HTTP REST API. This allows many different devices at multiple 
sites to communicate with the central gateway over a LAN/WAN or the internet, while also retrieving data
from a serial device connected locally. 

To enable the Ardtweeno gateway to speak to a specific serial device, a SerialParser implementation must be 
developed. The only requirement from the gateway's point of view is that it must interact with it through the
HTTP REST API.

In future releases, I hope to make the service interactable so that it may respond to commands received 
on twitter, or through web hooks and possibly an IRC bot.

This is a work in progress! The Wiki associated now contains the instructions for accessing the REST
API and installation instructions. Any bugs encountered can be raised on the issue tracker.

If you would like to collaborate with me on this project please fork the repository and send any changes
through a pull request! I gladly welcome constructive input!

# COPYING / Licence
This software is released under the GNU General Public License 3.0 Unported (CC BY-NC 3.0)
for more information see the full details of this licence here: http://creativecommons.org/licenses/by-nc/3.0/

For information regarding commercial use of the Ardtweeno Gateway, please contact the author at:
davidkirwanirl (_at_) gmail dot com or through Twitter at @kirwan\_david

# DISCLAIMER
All code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
