require 'rubygems'
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
  
end
