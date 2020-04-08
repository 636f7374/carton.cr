require "../src/carton.cr"

def handle_client(context : Carton::Context)
  STDOUT.puts context.stats

  context.perform
end

# Durian
servers = [] of Tuple(Socket::IPAddress, Durian::Protocol)
servers << Tuple.new Socket::IPAddress.new("8.8.8.8", 53_i32), Durian::Protocol::UDP
servers << Tuple.new Socket::IPAddress.new("1.1.1.1", 53_i32), Durian::Protocol::UDP
resolver = Durian::Resolver.new servers
resolver.ip_cache = Durian::Cache::IPAddress.new

# Carton
tcp_server = TCPServer.new "0.0.0.0", 1234_i32
carton = Carton::Server.new tcp_server, resolver
carton.authentication = Carton::Authentication::None
carton.client_timeout = Carton::TimeOut.new
carton.remote_timeout = Carton::TimeOut.new

# Authentication (Optional)
# carton.authentication = Carton::Authentication::Basic
# carton.on_auth = ->(user_name : String, password : String) do
#  STDOUT.puts [user_name, password]
#  Carton::Verify::Pass
# end

loop do
  socket = carton.accept?

  spawn do
    next unless client = socket
    next unless context = carton.upgrade client

    handle_client context
  end
end
