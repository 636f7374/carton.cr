module Orange
  enum Authentication : UInt8
    None  = 0_u8
    Basic = 1_u8
  end

  enum Verify : UInt8
    Pass = 0_u8
    Deny = 1_u8
  end

  enum Traffic : Int32
    HTTP  =  80_i32
    HTTPS = 443_i32
  end

  class AuthenticationFailed < Exception
  end

  class BadRequest < Exception
  end

  class BadResponse < Exception
  end

  class UnknownFlag < Exception
  end

  class MalformedPacket < Exception
  end

  class UnEstablish < Exception
  end

  class MismatchFlag < Exception
  end

  class AuthenticationEntry
    property userName : String
    property password : String?

    def initialize(@userName : String, @password : String?)
    end
  end

  class TimeOut
    property read : Int32
    property write : Int32
    property connect : Int32

    def initialize(@read : Int32 = 30_i32, @write : Int32 = 30_i32, @connect : Int32 = 10_i32)
    end
  end

  class RemoteAddress
    property host : String
    property port : Int32

    def initialize(@host : String, @port : Int32)
    end
  end

  def self.empty_io : IO::Memory
    memory = IO::Memory.new 0_i32
    memory.close

    memory
  end

  def self.establish_payload(version : String = "HTTP/1.1")
    String.build do |io|
      io << version << " " << "200" << " "
      io << "Connection established" << "\r\n\r\n"
    end
  end

  def self.deny_payload(version : String = "HTTP/1.1")
    String.build do |io|
      io << version << " " << "407" << " "
      io << "Proxy Authentication Required" << "\r\n\r\n"
    end
  end
end
