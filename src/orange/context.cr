module Orange
  class Context
    getter client : Socket
    getter dnsResolver : Durian::Resolver
    property timeout : TimeOut
    property clientEstablish : Bool
    property server : IO

    def initialize(@client : Socket, @dnsResolver : Durian::Resolver, @timeout : TimeOut = TimeOut.new)
      @clientEstablish = false
      @server = Orange.empty_io
    end

    def server=(value : IO)
      @server = value
    end

    def server
      @server
    end

    def stats
      Stats.from_socket client
    end

    def connect_server!
      return unless server.is_a? IO::Memory if server
      raise UnEstablish.new unless clientEstablish
      raise UnknownFlag.new unless remote_address = client.remote_address

      host = remote_address.address
      port = remote_address.port
      remote = Durian::TCPSocket.connect host, port, dnsResolver, timeout.connect

      self.server = remote
      remote.read_timeout = timeout.read
      remote.write_timeout = timeout.write

      remote
    end

    def all_close
      client.close rescue nil
      server.close rescue nil
    end

    def transport
      transport client, server
    end

    def transport(client, server : IO)
      channel = Channel(Bool).new

      spawn do
        IO.copy client, server rescue nil
        channel.send true
      end

      spawn do
        IO.copy server, client rescue nil
        channel.send true
      end

      all_close if channel.receive
      channel.receive
    end

    def perform
      begin
        connect_server!
      rescue ex
        return all_close
      end

      transport
    end

    def client_establish
      client_establish rescue nil
    end

    def reject_establish
      reject_establish rescue nil
      client.close
    end

    def client_establish!
      client.establish
      self.clientEstablish = true
    end

    private def reject_establish!
      return if clientEstablish

      client.reject_establish!
    end

    def reject_establish
      reject_establish! rescue nil

      all_close
    end
  end
end
