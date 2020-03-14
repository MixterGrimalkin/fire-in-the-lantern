require_relative '../lib/color'
require_relative '../lib/colors'
require_relative '../lib/color_tools'

class NeoPixel
  include Colors

  def initialize(pixel_count, mode: :rgb)
    @pixel_count = pixel_count
    @mode = mode
    @contents = [BLACK] * pixel_count
  end

  attr_reader :pixel_count, :mode, :contents

  def [](pixel)
    raise BadPixelNumber unless (0..pixel_count).include? pixel
    contents[pixel]
  end

  def []=(pixel, color)
    raise BadPixelNumber unless (0..pixel_count).include? pixel
    contents[pixel] = color
  end

  def on(color = FULL_WHITE)
    @contents = [color] * pixel_count
    render
  end

  def off
    @contents = [BLACK] * pixel_count
    render
  end

  def write(contents)
    raise BadPixelNumber unless contents.size == pixel_count
    @contents = contents
    self
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
    self
  end

  def show(buffer)
    # --> DO THING HERE <-- #
  end

  def rgb_count
    if mode == :rgbw
      ((pixel_count * 4) / 3.0).ceil
    else
      pixel_count
    end
  end

  def test
    print 'NeoPixel test running.'
    on RED
    sleep 1

    print '.'
    on GREEN
    sleep 1

    print '.'
    on BLUE
    sleep 1

    if mode == :rgbw
      print '.'
      on WARM_WHITE
      sleep 1
    end

    print '.'
    on
    sleep 1

    off
    puts 'OK'
  end

end

BadPixelNumber = Class.new(StandardError)
BadOutputMode = Class.new(StandardError)
