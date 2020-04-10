require_relative 'neo_pixel'
require 'osc-ruby'

class OscNeoPixel < NeoPixel

  def initialize(pixel_count:, mode:, host:, port:, address:)
    super(pixel_count: pixel_count, mode: mode)

    @client = OSC::Client.new(host, port)
    @address = address
  end

  def show(buffer)
    client.send OSC::Message.new("/#{address}", buffer.join(' '))
  end

  private

  attr_reader :client, :address

end
