require 'osc-ruby'
require 'osc-ruby/em_server'

class DirectOscServer
  include Utils

  def initialize(neo_pixel:, port:, address:, assets: Assets.new)
    @port, @address = port, address
    @server_ip = local_ip_address
    @assets = assets

    server.add_method "/#{address}" do |message|
      log_client message
      neo_pixel.show(unpack_buffer(message))
    end
  end

  attr_reader :server_ip, :port, :address

  def start
    Thread.new do
      server.run
    end
  end

  def to_s
    "Server @ #{server_ip}:#{port}/#{address}"
  end

  private

  def server
    @server ||= OSC::EMServer.new port
  end

  def clients
    @clients ||= {}
  end

  def unpack_buffer(message)
    message.to_a[0].split(' ').collect(&:to_i)
  end

  def log_client(message)
    ip, port = message.ip_address.to_s, message.ip_port.to_s
    unless clients[ip + port]
      message "Receiving data from: #{ip}:#{port}"
      clients[ip + port] = { ip: ip, port: port }
    end
  end

  attr_reader :assets
end
