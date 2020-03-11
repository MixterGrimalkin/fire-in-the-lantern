require_relative '../support/color'
require_relative '../support/color_constants'

class NeoPixel
  include ::ColorConstants

  def initialize(pixel_count, mode: :rgb)
    @pixel_count = pixel_count
    @mode = mode
    @contents = [BLACK] * pixel_count
  end

  attr_accessor :contents

  attr_reader :pixel_count, :mode

  def set(pixel, color)
    raise PixelOutOfRangeError unless (0..pixel_count).include? pixel

    contents[pixel] = color
  end

  def set_range(start, width, color)
    width.times do |i|
      set start+i, color
    end
  end

  def fill(color = BLACK)
    set_range 0, pixel_count, color
  end

  def all_on
    @contents = [WHITE] * pixel_count
    render
  end

  def all_off
    @contents = [BLACK] * pixel_count
    render
  end

  def rgb_count
    if mode == :rgbw
      ((pixel_count * 4) / 3.0).ceil
    else
      pixel_count
    end
  end

  def render
    buffer = contents.collect do |color|
      case mode
        when :rgb
          [color.red, color.green, color.blue]
        when :grb
          [color.green, color.red, color.blue]
        when :rgbw
          [color.red, color.green, color.blue, color.white || 0]
        else
          raise BadOutputMode, mode.to_s
      end
    end.flatten
    while buffer.size % 3 != 0
      buffer << 0
    end
    show buffer
  end

  def show(buffer); end

end

class PixelOutOfRangeError < StandardError; end
class NeoPixelStartedError < StandardError; end
class NeoPixelNotStartedError < StandardError; end
class BadOutputMode < StandardError; end