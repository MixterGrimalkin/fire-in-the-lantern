require './neopixel/neopixel'
require 'osc-ruby'

module Fitl
  class OscNeopixel < Neopixel
    def initialize(pixel_count:, mode:, host:, port:, address:)
      super(pixel_count: pixel_count, mode: mode)
      @host, @port, @address = host, port, address
      client
    end

    def show(buffer)
      client.send OSC::Message.new("/#{address}", buffer.join(' '))
    end

    attr_reader :host, :port, :address

    private

    def client
      @client ||= OSC::Client.new(host, port)
    end
  end
end
