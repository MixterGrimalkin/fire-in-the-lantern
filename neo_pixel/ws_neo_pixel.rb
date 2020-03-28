require_relative 'neo_pixel'
require 'forwardable'
require 'ws2812'

class WsNeoPixel < NeoPixel
  extend Forwardable

  def initialize(pixel_count, pin: 18, mode: :rgb, brightness: 127, options: {})
    super(pixel_count, mode: mode)
    @ws = Ws2812::Basic.new(pixel_count, pin, brightness, options)
    ws.open
  end

  attr_reader :ws

  def_delegators :ws, :close, :brightness, :brightness=

  def show(buffer)
    p = 0
    buffer.each_slice(3) do |rgb|
      ws[p] = Ws2812::Color.new(rgb[0], rgb[1], rgb[2])
      p += 1
    end
    ws.show
  end

end
