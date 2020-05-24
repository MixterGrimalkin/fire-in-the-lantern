require_relative 'neo_pixel'
require 'forwardable'
require 'ws2812'

class WsNeoPixel < NeoPixel
  extend Forwardable

  def initialize(pixel_count:, mode:, pin:, brightness:, options: {})
    super(pixel_count: pixel_count, mode: mode)
    @ws = Ws2812::Basic.new(rgb_count, pin, brightness, options)
    ws.open
  end

  attr_reader :ws

  def_delegators :ws, :close, :brightness, :brightness=

  def show(buffer)
    p = 0
    buffer.each_slice(3) do |slice|
      ws[p] = Ws2812::Color.new(slice[0], slice[1], slice[2])
      p += 1
    end
    ws.show
  end

end
