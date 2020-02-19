require_relative 'neo_pixel'
require 'net/http'

class HttpNeoPixel < NeoPixel

  def initialize(pixel_count, host: 'localhost', port: 4567)
    super(pixel_count, mode: :rgb)
    @uri = URI("http://#{host}:#{port}/data")
  end

  def show(buffer)
    Net::HTTP.post(@uri, "data=[#{buffer.join(',')}]")
  end

end
