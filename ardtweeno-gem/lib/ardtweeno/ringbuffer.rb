####################################################################################################
# @author       David Kirwan https://github.com/davidkirwan/ardtweeno
# @description  Ardtweeno::RingBuffer storage class
#
# @date         2013-08-18
####################################################################################################

require 'ardtweeno'


module Ardtweeno
  class RingBuffer
  
  
    ##
    # Ardtweeno::RingBuffer#new Constructor
    #
    # * *Args*    :
    #   - ++ ->   Fixnum size
    # * *Returns* :
    #   -         An instanciated copy of the RingBuffer class
    # * *Raises* :
    #             TypeError if size is of type other than a Fixnum,
    #             ArgumentError if size is < 1
    #
    def initialize(size)
      unless size.class == Fixnum then raise TypeError, "Size must be a Fixnum"; end
      unless size >= 1 then raise ArgumentError, "Size must be a Fixnum of size >= 1"; end
      @max = size
      @buffer = []
    end
    
    
    
    ##
    # Ardtweeno::RingBuffer#push This method adds an element at the end of the buffer, if size is exceeded, 
    # the first element is dropped
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #             
    def push(line)
      if @buffer.size == @max
        @buffer.shift
      end
      @buffer.push(line)
    end
    
    
    
    ##
    # Ardtweeno::RingBuffer#clear empties the internal buffer
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #
    def clear 
      @buffer = []
    end
    
    
    
    ##
    # Ardtweeno::RingBuffer#to_a
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         Copy of the internal buffer in Array form
    # * *Raises* :
    #
    def to_a
      return @buffer.dup
    end
    
    
    
    ##
    # Ardtweeno::RingBuffer#to_s converts the internal buffer to a String 
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         String representation of the internal buffer
    # * *Raises* :
    #
    def to_s
      return @buffer.to_s  
    end
    
    
    
    ##
    # Ardtweeno::RingBuffer#each call the closure block on each element in the buffer 
    #
    # * *Args*    :
    #   - ++ ->   
    # * *Returns* :
    #   -         
    # * *Raises* :
    #
    def each(&block)
      @buffer.each(&block)
    end
    
    
    
  end # End of RingBuffer class
end # End of Ardtweeno module