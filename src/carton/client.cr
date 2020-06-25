class Carton::Client < IO
  property wrapped : IO

  def initialize(@wrapped : IO)
  end

  def self.new(host : String, port : Int32, dnsResolver : Durian::Resolver = Durian::Resolver.new, connectTimeout : Int | Float? = nil)
    wrapped = Durian::TCPSocket.connect host, port, dnsResolver, connectTimeout

    new wrapped
  end

  def self.new(ip_address : ::Socket::IPAddress, dnsResolver : Durian::Resolver = Durian::Resolver.new, connectTimeout : Int | Float? = nil)
    wrapped = TCPSocket.connect ip_address, connectTimeout

    new wrapped
  end

  def self.new(host : String, port : Int32, dnsResolver : Durian::Resolver = Durian::Resolver.new, timeout : TimeOut = TimeOut.new)
    wrapped = Durian::TCPSocket.connect host, port, dnsResolver, timeout.connect
    wrapped.read_timeout = timeout.read
    wrapped.write_timeout = timeout.write

    new wrapped
  end

  def self.new(ip_address : ::Socket::IPAddress, dnsResolver : Durian::Resolver = Durian::Resolver.new, timeout : TimeOut = TimeOut.new)
    wrapped = TCPSocket.connect ip_address, connectTimeout, timeout.connect
    wrapped.read_timeout = timeout.read
    wrapped.write_timeout = timeout.write

    new wrapped
  end

  def on_auth=(value : AuthenticationEntry)
    @onAuth = value
  end

  def on_auth
    @onAuth
  end

  def authentication=(value : Authentication)
    @authentication = value
  end

  def authentication
    @authentication || Authentication::None
  end

  def traffic_type=(value : Traffic)
    @trafficType = value
  end

  def traffic_type
    @trafficType
  end

  def read(slice : Bytes) : Int32
    wrapped.read slice
  end

  def write(slice : Bytes) : Nil
    wrapped.write slice
  end

  def <<(value : String) : IO
    wrapped << value

    self
  end

  def flush
    wrapped.flush
  end

  def close
    wrapped.close
  end

  def closed?
    wrapped.closed?
  end

  def read_timeout=(value : Int | Float | Time::Span | Nil)
    _wrapped = wrapped

    _wrapped.read_timeout = value if value if _wrapped.responds_to? :read_timeout=
  end

  def write_timeout=(value : Int | Float | Time::Span | Nil)
    _wrapped = wrapped

    _wrapped.write_timeout = value if value if _wrapped.responds_to? :write_timeout=
  end

  def read_timeout
    _wrapped = wrapped
    _wrapped.read_timeout if _wrapped.responds_to? :read_timeout
  end

  def write_timeout
    _wrapped = wrapped
    _wrapped.write_timeout if _wrapped.responds_to? :write_timeout
  end

  def connect!(ip_address : ::Socket::IPAddress)
    connect! wrapped, ip_address.address, ip_address.port
  end

  def connect!(host : String, port : Int32)
    connect! wrapped, host, port
  end

  def connect!(socket : IO, host : String, port : Int32, version : String = "HTTP/1.1")
    handshake! socket, host, port, version
  end

  def build_handshake!(host, port, version : String = "HTTP/1.1") : HTTP::Request
    resource = String.build { |io| io << host << ":" << port.to_s }
    request = HTTP::Request.new "CONNECT", resource, version: version
    request.header_host = resource

    case authentication
    when .basic?
      raise UnknownFlag.new unless _on_auth = on_auth

      auth = String.build { |io| io << _on_auth.userName << ":" << _on_auth.password }
      payload = String.build { |io| io << "Basic" << " " << Base64.strict_encode auth }
      request.headers["Proxy-Authorization"] = payload
    end

    request
  end

  def handshake!(socket : IO, host : String, port : Int32, version : String = "HTTP/1.1")
    return if traffic_type == Traffic::HTTP

    request = build_handshake! host, port, version
    request.to_io socket
    socket.flush

    response = HTTP::Client::Response.from_io socket, ignore_body: true
    raise BadResponse.new unless message = response.status_message
    raise BadResponse.new unless message.downcase == "connection established"
    raise AuthenticationFailed.new if response.status.proxy_authentication_required?
    raise BadResponse.new unless response.status.ok?
  end
end
