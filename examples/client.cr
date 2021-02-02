require "../src/carton.cr"

# Durian

dns_servers = [] of Durian::Resolver::Server
dns_servers << Durian::Resolver::Server.new ipAddress: Socket::IPAddress.new("8.8.8.8", 53_i32), protocol: Durian::Protocol::UDP
dns_servers << Durian::Resolver::Server.new ipAddress: Socket::IPAddress.new("1.1.1.1", 53_i32), protocol: Durian::Protocol::UDP

dns_resolver = Durian::Resolver.new dns_servers
dns_resolver.ip_cache = Durian::Cache::IPAddress.new

# Carton

begin
  client = Carton::Client.new "0.0.0.0", 1234_i32, dns_resolver

  # Authentication (Optional)
  # client.authentication = Carton::Authentication::Basic
  # client.on_auth = Carton::AuthenticationEntry.new "admin", "abc123"

  # Handshake

  client.connect! "www.example.com", 80_i32

  # Write Payload

  request = HTTP::Request.new "GET", "http://www.example.com"
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
