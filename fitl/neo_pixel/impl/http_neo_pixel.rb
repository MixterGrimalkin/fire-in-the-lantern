require_relative '../neo_pixel'

require 'net/http'

class HttpNeoPixel < NeoPixel

  def initialize(pixel_count:, mode:, host:, port:, path:)
    super(pixel_count: pixel_count, mode: mode)
    @host, @port, @path = host, port, path
    uri
  end

  def show(buffer)
    Net::HTTP.post @uri, "data=[#{buffer.join(',')}]"
  end

  attr_reader :host, :port, :path

  private

  def uri
    @uri ||= URI("http://#{host}:#{port}/#{path}")
  end
end
