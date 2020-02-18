require_relative 'neo_pixel'
require 'net/http'

class NeoPixelHttp < NeoPixel

  def initialize(pixel_count)
    super(pixel_count, mode: :rgb)
    @uri = URI('http://localhost:4567/data')
  end

  def show(buffer)
    Net::HTTP.post(@uri, "data=[#{buffer.join(',')}]")
  end

end
