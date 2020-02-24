require_relative '../support/color'
require_relative '../support/color_constants'

class PixelLayer
  include ColorConstants

  def initialize(key, pixels, default = nil)
    @key = key
    @pixels = pixels
    @contents = [default] * pixels.size
    @opacity = 1.0

    @scroll_offset = 0
    @scroll_period = nil
    @scroll_last_updated = nil
  end

  attr_accessor :opacity, :contents

  attr_reader :pixels, :scroll_offset, :scroll_period, :key

  def []=(pixel, color)
    contents[pixel] = color
  end

  def fill(color, brightness = 1.0)
    pixels.size.times do |i|
      contents[i] = color&.with_brightness(brightness)
    end
  end

  def gradient(red: [0, 0], green: [0, 0], blue: [0, 0])
    s_red, s_green, s_blue = red[0], green[0], blue[0]
    d_red = (red[1] - s_red) / (pixels.size - 1)
    d_green = (green[1] - s_green) / (pixels.size - 1)
    d_blue = (blue[1] - s_blue) / (pixels.size - 1)
    pixels.size.times do |i|
      contents[i] = Color.new(s_red, s_green, s_blue)
      s_red += d_red
      s_green += d_green
      s_blue += d_blue
    end
    self
  end

  def scroll_by(amount)
    @scroll_offset += amount
  end

  def start_scroll(period)
    @scroll_period = period
    @scroll_last_updated = Time.now
  end

  def stop_scroll
    @scroll_last_updated = nil
  end

  def update_scroll(elapsed_seconds)
    return unless @scroll_last_updated

    if elapsed_seconds >= @scroll_period
      @scroll_offset += (elapsed_seconds / @scroll_period)
      @scroll_last_updated = Time.now
    end
  end

  def update
    update_scroll Time.now - @scroll_last_updated if @scroll_last_updated
  end

  def render_over(base_layer)
    contents.each_with_index do |color, i|
      unless color.nil?
        p = (pixels[i] + @scroll_offset) % base_layer.size
        base_layer[p] = color.blend_over(base_layer[p], opacity)
      end
    end
    base_layer
  end

  def combine_keys(other)
    (key.to_s + other.key.to_s).to_sym
  end

  def ==(other)
    pixels == other.pixels
  end

  def +(other)
    PixelLayer.new(
        combine_keys(other),
        pixels + other.pixels)
  end

  def -(other)
    PixelLayer.new(
        combine_keys(other),
        pixels - other.pixels
    )
  end

  def layer_def
    result = {
        key: key,
        pixels: pixels,
        contents: contents,
        opacity: opacity
    }
    if @scroll_last_updated
      result[:scroll] = @scroll_period
    end
    result
  end

end