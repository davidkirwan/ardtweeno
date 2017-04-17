=begin
####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno Gateway
#
# @date         2014-08-12
####################################################################################################

This file is part of Ardtweeno.

Ardtweeno is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

Ardtweeno is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
=end


require 'ardtweeno'

module Ardtweeno

  class DBError < Exception
  end

  class InvalidData < Exception
  end
  
  class NotANode < Exception
  end

  class NotInNodeList < Exception
  end
  
  class NotAPacket < Exception
  end

  class PacketListEmpty < Exception
  end
  
  class ManagerNotDefined < Exception
  end

  class NodeNotAuthorised < Exception
  end
  
  class SerialDeviceNotFound < Exception
  end
  
  class InvalidWatch < Exception  
  end
  
  class AlreadyWatched < Exception
  end
  
  class SensorException < Exception
  end

  class InvalidSerialSpeedException < Exception
  end

  class InvalidSerialDeviceException < Exception
  end

  class MalformedZoneJSONException < Exception
  end

  class MalformedNodeJSONException < Exception
  end
end
