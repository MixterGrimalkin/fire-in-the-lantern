require_relative '../support/color'

class PixelLayer

  def initialize(pixels)
    @pixels = pixels
  end

  attr_reader :pixels

  def ==(other)
    pixels == other.pixels
  end

  def +(other)
    PixelLayer.new(pixels + other.pixels)
  end

  def -(other)
    PixelLayer.new(pixels - other.pixels)
  end

  def set(color, brightness = 1.0)
    pixels.each do |p|
      p.set color, brightness
    end
  end

  def color=(color)
    pixels.each do |p|
      p.color = color
    end
  end

  def brightness=(brightness)
    pixels.each do |p|
      p.brightness = brightness
    end
  end

  def gradient(red: [0,0], green: [0,0], blue: [0,0])
    s_red, s_green, s_blue = red[0], green[0], blue[0]
    d_red = (red[1] - s_red) / (pixels.size - 1)
    d_green = (green[1] - s_green) / (pixels.size - 1)
    d_blue = (blue[1] - s_blue) / (pixels.size - 1)
    pixels.each do |p|
      p.set Color.new(s_red, s_green, s_blue)
      s_red += d_red
      s_green += d_green
      s_blue += d_blue
    end
    self
  end

end