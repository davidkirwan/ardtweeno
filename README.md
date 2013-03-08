# Ardtweeno - Application Gateway
Ardtweeno is an application gateway which bridges an XBEE/Zigbee 802.15.4 radio mesh network and an Internet 
Protocol network. The system is designed as a PaaS (platform as a service) for the Raspberry Pi ARM platform.
All data received on the mesh network interface is stored to a database. The gateway exposes a HTTP REST API 
for configuration and data manipulation purposes which can be queried in order to build statistics, graphs 
and other forms of data reporting. Push notifications, twitter and dropbox integration is planned in later 
releases.

## Release Schedule
While the system is still under development, ER1 (Minimum Viable Product) is now complete and waiting to be
released. Development is currently focused on a sample web application which consumes the Ardtweeno API, and
updating the documentation to reflect the latest system features to be implemented.

I've decided to release the system on _github_ with ER2 towards the end of May 2013 during the student fair
at the Waterford Institute of Technology.

## Project Poster
![Ardtweeno](http://davidkirwan.github.com/ardtweeno/ardtweeno-poster.png)

## Project Licence
The Ardtweeno Application Gateway is released under the Creative Commons Attribution-NonCommercial 3.0 Unported 
licence. For more information please see _COPYING_.
