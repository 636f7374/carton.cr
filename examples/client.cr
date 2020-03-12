require "../src/orange.cr"

# Durian
servers = [] of Tuple(Socket::IPAddress, Durian::Protocol)
servers << Tuple.new Socket::IPAddress.new("8.8.8.8", 53_i32), Durian::Protocol::UDP
servers << Tuple.new Socket::IPAddress.new("1.1.1.1", 53_i32), Durian::Protocol::UDP
resolver = Durian::Resolver.new servers
resolver.ip_cache = Durian::Cache::IPAddress.new

# Orange
begin
  client = Orange::Client.new "0.0.0.0", 1234_i32, resolver

  # Authentication (Optional)
  # client.authentication = Orange::Authentication::Basic
  # client.on_auth = Orange::SimpleAuth.new "admin", "abc123"

  # Handshake
  client.connect! "www.example.com", 80_i32

  # Write Payload
  request = HTTP::Request.new "GET", "www.example.com:80"
  request.header_host = "www.example.com:80"
  request.to_io client

  # Read Payload
  buffer = uninitialized UInt8[4096_i32]
  length = client.read buffer.to_slice

  STDOUT.puts [:length, length]
  STDOUT.puts String.new buffer.to_slice[0_i32, length]
rescue ex
  STDOUT.puts [ex]
end

client.try &.close
