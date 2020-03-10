require "../src/orange.cr"

def handle_client(context : Orange::Context)
  STDOUT.puts context.summary

  context.perform
end

# Durian
servers = [] of Tuple(Socket::IPAddress, Durian::Protocol)
servers << Tuple.new Socket::IPAddress.new("8.8.8.8", 53_i32), Durian::Protocol::UDP
servers << Tuple.new Socket::IPAddress.new("1.1.1.1", 53_i32), Durian::Protocol::UDP
resolver = Durian::Resolver.new servers
resolver.ip_cache = Durian::Cache::IPAddress.new

# Orange
tcp_server = TCPServer.new "0.0.0.0", 1234_i32
orange = Orange::Server.new tcp_server, resolver
orange.authentication = Orange::Authentication::None
orange.client_timeout = Orange::TimeOut.new
orange.remote_timeout = Orange::TimeOut.new

# Authentication (Optional)
# orange.authentication = Orange::Authentication::Basic
# orange.on_auth = ->(user_name : String, password : String) do
#  STDOUT.puts [user_name, password]
#  Orange::Verify::Pass
# end

loop do
  socket = orange.accept?

  spawn do
    next unless client = socket
    next unless context = orange.upgrade client

    handle_client context
  end
end
