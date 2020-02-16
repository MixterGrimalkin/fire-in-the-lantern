require_relative '../support/color'
require_relative '../support/color_constants'

class NeoPixel
  include ::ColorConstants

  def initialize(pixel_count, output: :rgb)
    @pixel_count = pixel_count
    @output = output
    @contents = [BLACK] * pixel_count
    @started = false
    render
  end

  attr_reader :pixel_count, :output, :contents, :started

  def set(pixel, rgb)
    raise PixelOutOfRangeError unless (0..pixel_count).include? pixel

    contents[pixel] = rgb
  end

  def set_range(start, width, color)
    width.times do |i|
      set start+i, color
    end
  end

  def all_on
    set_range 0, pixel_count, WHITE
    render
  end

  def all_off
    set_range 0, pixel_count, BLACK
    render
  end

  def start(period = 0.01)
    raise NeoPixelStartedError if @started

    @started = true
    Thread.new do
      while @started
        render
        sleep period
      end
    end
  end

  def stop
    raise NeoPixelNotStartedError unless @started

    @started = false
  end

  def render
    buffer = contents.collect do |color|
      case output
        when :rgb
          [color.red, color.green, color.blue]
        when :grb
          [color.green, color.red, color.blue]
        when :rgbw
          [color.red, color.green, color.blue, color.white || 0]
        else
          raise BadOutputMode, output.to_s
      end
    end.flatten
    while buffer.size % 3 != 0
      buffer << 0
    end
    show buffer
  end

  priv36ate

  def show(buffer)

  end

end

class PixelOutOfRangeError < StandardError; end
class NeoPixelStartedError < StandardError; end
class NeoPixelNotStartedError < StandardError; end
class BadOutputMode < StandardError; end