struct Orange::Summary
  def initialize
  end

  def client_authentication=(value : Authentication?)
    @clientAuthentication = value
  end

  def remote_address=(value : RemoteAddress?)
    @remoteAddress = value
  end

  def request_payload=(value : HTTP::Request?)
    @requestPayload = value
  end

  def request_payload
    @requestPayload
  end

  def traffic_type=(value : Traffic?)
    @trafficType = value
  end

  def traffic_type
    @trafficType
  end

  def tunnel_mode=(value : Bool?)
    @tunnelMode = value
  end

  def tunnel_mode
    @tunnelMode
  end

  def self.from_socket(socket : Socket)
    summary = new

    summary.client_authentication = socket.client_authentication
    summary.remote_address = socket.remote_address
    summary.request_payload = socket.request_payload
    summary.tunnel_mode = socket.tunnel_mode
    summary.traffic_type = socket.traffic_type

    summary
  end
end
