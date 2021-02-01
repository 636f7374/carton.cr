class Carton::Context
  getter source : Socket
  getter dnsResolver : Durian::Resolver
  property timeout : TimeOut
  property sourceEstablish : Bool
  property destination : IO

  def initialize(@source : Socket, @dnsResolver : Durian::Resolver, @timeout : TimeOut = TimeOut.new)
    @sourceEstablish = false
    @destination = Carton.empty_io
  end

  def destination=(value : IO)
    @destination = value
  end

  def destination
    @destination
  end

  def stats
    Stats.from_socket source
  end

  def connect_destination!
    return unless destination.is_a? IO::Memory if destination
    raise UnEstablish.new unless sourceEstablish
    raise UnknownFlag.new unless destination_address = source.destination_address

    host = destination_address.host
    port = destination_address.port
    destination = Durian::TCPSocket.connect host, port, dnsResolver, timeout.connect

    self.destination = destination
    destination.read_timeout = timeout.read
    destination.write_timeout = timeout.write

    destination
  end

  def all_close
    source.close rescue nil
    destination.close rescue nil
  end

  def transport
    _transport = Transport.new source, destination
    _transport.perform
  end

  def perform
    begin
      connect_destination!
    rescue ex
      return all_close
    end

    transport
  end

  def source_establish
    source_establish rescue nil
  end

  def reject_establish
    reject_establish rescue nil
    source.close
  end

  def source_establish!
    source.establish
    self.sourceEstablish = true
  end

  private def reject_establish!
    return if sourceEstablish

    source.reject_establish!
  end

  def reject_establish
    reject_establish! rescue nil

    all_close
  end
end
