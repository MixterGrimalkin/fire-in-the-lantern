require_relative 'neo_pixel'
require 'net/http'

class HttpNeoPixel < NeoPixel

  def initialize(pixel_count, mode: :rgb, host: 'localhost', port: 4567, path: 'data')
    super(pixel_count, mode)
    @uri = URI("http://#{host}:#{port}/#{path}")
  end

  def show(buffer)
    Net::HTTP.post(@uri, "data=[#{buffer.join(',')}]")
  rescue => e
    puts e.message
  end

end
