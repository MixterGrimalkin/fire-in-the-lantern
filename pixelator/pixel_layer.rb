require_relative '../support/color'
require_relative '../support/color_constants'

class PixelLayer
  include ColorConstants

  def initialize(pixels, default = nil)
    @pixels = pixels
    @contents = [default] * pixels.size
    @opacity = 1.0
  end

  attr_reader :pixels, :contents

  attr_accessor :opacity

  def render_over(base_layer)
    @contents.each_with_index do |color, i|
      unless color.nil?
        base_layer[pixels[i]] =
            color.blend_over(base_layer[pixels[i]], opacity)
      end
    end
    base_layer
  end

  def blend(base_color, new_color)
    return base_color if new_color.nil?
    new_color
  end

  def fill(color, brightness = 1.0)
    contents.size.times do |i|
      contents[i] = color&.with_brightness(brightness)
    end
  end

  def gradient(red: [0, 0], green: [0, 0], blue: [0, 0])
    s_red, s_green, s_blue = red[0], green[0], blue[0]
    d_red = (red[1] - s_red) / (pixels.size - 1)
    d_green = (green[1] - s_green) / (pixels.size - 1)
    d_blue = (blue[1] - s_blue) / (pixels.size - 1)
    pixels.size.times do |i|
      @contents[i] = Color.new(s_red, s_green, s_blue)
      s_red += d_red
      s_green += d_green
      s_blue += d_blue
    end
    self
  end

  def []=(pixel, color)
    @contents[pixel] = color
  end

  def ==(other)
    pixels == other.pixels
  end

  def +(other)
    PixelLayer.new(pixels + other.pixels)
  end

  def -(other)
    PixelLayer.new(pixels - other.pixels)
  end

end