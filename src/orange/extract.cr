module Orange
  class Extract < IO
    property extract : IO::Memory
    property wrapped : IO
    property sync_close : Bool
    property? closed : Bool

    def initialize(@wrapped, @extract, @sync_close : Bool = true)
      @closed = false
    end

    def self.new(wrapped, extract, sync_close : Bool = true, &block : Extract ->)
      yield new wrapped, extract, sync_close
    end

    def self.part(wrapped : IO, &block : Extract ->)
      yield part wrapped
    end

    def self.part(wrapped : IO)
      part! wrapped rescue IO::Memory.new 0_i32
    end

    def self.part!(wrapped : IO, &block : Extract ->)
      yield part! wrapped
    end

    def self.part!(wrapped : IO) : IO::Memory
      buffer = uninitialized UInt8[24576_i32]
      length = wrapped.read buffer.to_slice

      IO::Memory.new String.new buffer.to_slice[0_i32, length]
    end

    def extract_eof?
      extract.pos == extract.size
    end

    def write(slice : Bytes) : Nil
    end

    def read(slice : Bytes)
      if extract.closed?
        return wrapped.read slice
      end

      length = extract.read slice
      extract.close if extract_eof?
      length
    end

    def closed?
      @closed
    end

    def close
      return if closed?
      @closed = true
      extract.close

      if sync_close
        wrapped.close
      end
    end
  end
end
