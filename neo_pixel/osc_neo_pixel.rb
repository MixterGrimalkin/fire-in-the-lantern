require_relative 'neo_pixel'
require_relative 'text_neo_pixel'
require 'osc-ruby'

class OscNeoPixel < NeoPixel

  def initialize(pixel_count, mode: :rgb, host: 'localhost', port: 3333)
    super(pixel_count, mode: mode)
    @client = OSC::Client.new(host, port)
    @text_out = TextNeoPixel.new(pixel_count)
    @echo = false
  end

  attr_accessor :echo

  def show(buffer)
    @client.send(OSC::Message.new('/data', buffer.join(' ')))
    if echo
      @text_out.show buffer
    end
  rescue => e
    puts e.message
    puts '!Stopping NeoPixelOsc!'
    stop
  end

end
