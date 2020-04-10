require_relative 'neo_pixel'
require 'net/http'

class HttpNeoPixel < NeoPixel

  def initialize(pixel_count:, mode:, host:, port:, path:)
    super(pixel_count: pixel_count, mode: mode)

    @uri = URI("http://#{host}:#{port}/#{path}")
  end

  def show(buffer)
    Net::HTTP.post @uri, "data=[#{buffer.join(',')}]"
  end

end
