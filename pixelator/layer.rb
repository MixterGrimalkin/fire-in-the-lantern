require_relative '../lib/color'
require_relative '../lib/colors'
require_relative '../lib/color_tools'

class Layer
  include Colors
  include ColorTools

  def initialize(pixels, default = nil)
    @pixels = pixels
    @contents = [default] * pixels.size
    @layer_opacity = 1.0
    @pixel_opacity = [1.0] * pixels.size
    @scroll_offset = 0
    @scroll_period = nil
    @scroll_last_updated = nil
  end

  attr_accessor :layer_opacity, :pixel_opacity, :contents

  attr_reader :pixels, :scroll_offset, :scroll_period

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, opacity = 1.0)
    raise PixelOutOfRangeError unless (0..(pixels.size-1)).include?(pixel)
    contents[pixel] = color
    pixel_opacity[pixel] = opacity
  end

  def fill(color, brightness = 1.0)
    pixels.size.times do |i|
      contents[i] = color.nil? ? nil : color.with_brightness(brightness)
    end
  end

  def gradient(config)
    grad = draw_gradient(pixels.size, config)
    @contents = grad[:colors]
    @pixel_opacity = grad[:alphas]
    self
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
        base_layer[p] = color.blend_over(base_layer[p], opacity_for_pixel(i))
      end
    end
    base_layer
  end

  def ==(other)
    pixels == other.pixels
  end

  def +(other)
    Layer.new(pixels + other.pixels)
  end

  def -(other)
    Layer.new(pixels - other.pixels)
  end

  def layer_def
    result = {
        pixels: pixels,
        contents: contents.collect { |c| c.nil? ? BLACK : c },
        opacity: layer_opacity,
        pixel_opacity: pixel_opacity
    }
    if @scroll_last_updated
      result[:scroll] = @scroll_period
    end
    result
  end

  def inspect
    "#<Layer{#{pixels.size}} α=#{layer_opacity} [#{stringify_scroll_period}]>"
  end

  private

  def stringify_scroll_period
    if scroll_period.nil?
      '-0.0-'
    elsif scroll_period > 0
      "-#{scroll_period}>"
    else
      "<#{-scroll_period}-"
    end
  end

  def opacity_for_pixel(p)
    pixel_opacity[p] * layer_opacity
  end

end

class PixelOutOfRangeError < StandardError;
end