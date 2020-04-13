require_relative '../lib/utils'
require 'osc-ruby'
require 'osc-ruby/em_server'
require 'socket'

class OscServer
  include Utils

  def initialize(neo_pixel:, port: '3333', address: 'neo_pixel')
    @server_port = port
    @osc_address = address
    @clients = {}

    @server_ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    @server = OSC::EMServer.new server_port

    server.add_method "/#{osc_address}" do |message|
      log_client message
      buffer = message.to_a[0].split(' ').collect(&:to_i)
      neo_pixel.show(buffer)
    end
  end

  attr_reader :server, :clients, :server_ip, :server_port, :osc_address

  def start
    Thread.new do
      message "Starting Server: #{server_ip}:#{server_port}/#{osc_address}"
      server.run
    end
  end

  private

  def log_client(message)
    ip, port = message.ip_address.to_s, message.ip_port.to_s
    unless clients[ip + port]
      message "Receiving data from: #{ip}:#{port}"
      clients[ip + port] = { ip: ip, port: port }
    end
  end

end
