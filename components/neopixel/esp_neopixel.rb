require './components/neopixel/neopixel'

require 'websocket-client-simple'

require 'osc-ruby'
require 'osc-ruby/em_server'

module Fitl
  class EspNeopixel < Neopixel
    SOCKET_NAME = 'ws'.freeze

    def initialize(pixel_count:, mode:, ip_address:)
      super(pixel_count: pixel_count, mode: :rgb)
      @ip_address = ip_address
      connect
      # client
    end

    def show(buffer)
      message = ''
      buffer.each_slice(3) do |r,g,b|
        message += "#{r},#{g},#{b} "
      end
      send_ws_message message.strip
    end

    def web_socket
      @web_socket ||= WebSocket::Client::Simple.connect "ws://#{ip_address}/#{SOCKET_NAME}"
    end

    def send_ws_message(message)
      connect unless web_socket&.open?
      web_socket.send message
    end

    def send_osc(address, *message)
      # client.send OSC::Message.new(address, *message)
    end

    attr_reader :ip_address

    def connect
      web_socket&.close
      @web_socket = nil
      ip = ip_address
      neo = self
      web_socket.on :open do
        puts "WebSocket open to #{ip}"
      end
      web_socket.on :message do |msg|
        neo.receive_ws_message msg
      end
      web_socket.on :error do |e|
        puts "Error: #{e}"
      end
      web_socket.on :close do |e|
        puts "Closed: #{e}"
      end
    end

    def receive_ws_message(message)
      # puts "RECEIVED: #{message}"
    end

    attr_accessor :waiting_for_info

    def client
      # @client ||= OSC::Client.new(ip_address, ESP_PORT)
    end

  end
end