# Ardtweeno - Application Gateway
Ardtweeno is an application gateway which bridges an XBEE/Zigbee 802.15.4 radio mesh network and an Internet 
Protocol network. The system is designed as a PaaS (platform as a service) for the Raspberry Pi ARM platform.
All data received on the mesh network interface is stored to a MongoDB database if one is available otherwise
stores the data in system RAM. The gateway exposes a HTTP REST API for configuration and data manipulation 
purposes which can be queried in order to build statistics, graphs and other forms of data reporting. Push 
notifications, twitter and dropbox integration is planned in later releases.

## Usage Instructions
See the WIKI for information regarding configuration and installation, and here for usage instructions: [usage](http://davidkirwan.github.io/ardtweeno)

## Project Poster
![Ardtweeno](http://davidkirwan.github.io/ardtweeno/ardtweeno-poster.png)

## Project Licence
The Ardtweeno Application Gateway is released under the Creative Commons Attribution-NonCommercial 3.0 Unported 
licence. For more information please see _COPYING_.
