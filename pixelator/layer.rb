require_relative '../lib/color'
require_relative '../lib/color_a'
require_relative '../lib/colors'
require_relative '../lib/color_tools'
require_relative '../lib/errors'
require_relative 'scroller'

class Layer
  include Colors
  include ColorTools

  def initialize(pixels, default = nil)
    @pixels = pixels
    @layer_opacity = 1.0
    @pattern = [ColorA.new(default)] * pixel_count
    @scroller = Scroller.new
  end

  attr_accessor :layer_opacity, :pixel_opacity, :pattern

  attr_reader :pixels, :scroller

  def pixel_count
    pixels.size
  end

  def color_array
    pattern.collect(&:color)
  end

  def alpha_array
    pattern.collect(&:alpha)
  end

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, alpha = 1.0)
    raise PixelOutOfRangeError unless (0..(pixel_count-1)).include?(pixel)

    pattern[pixel] = ColorA.new(color, alpha)
  end

  def fill(color, brightness = 1.0)
    pixel_count.times do |i|
      pattern[i] = ColorA.new(color.nil? ? nil : color.with_brightness(brightness), 1.0)
    end
  end

  def gradient(config)
    @pattern = draw_gradient(pixels.size, config)
    self
  end

  def update
    scroller.check_and_update
  end

  def expand(canvas_size)
    result = [ColorA.new] * canvas_size
    pattern.each_with_index do |color_a, i|
      result[pixels[i]] = color_a
    end
    result
  end

  def render_over(base_layer)
    buffer = scroller.scroll(expand(base_layer.size))
    buffer.each_with_index do |color_a, i|
      unless color_a.nil? || color_a.color.nil?
        base_layer[i] = color_a.color.blend_over(base_layer[i], color_a.alpha * layer_opacity)
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
        contents: pattern.collect { |ca| ca.color.nil? ? BLACK : ca.color },
        opacity: layer_opacity,
        pixel_opacity: pattern.collect { |ca| ca.alpha }
    }
    if scroller.last_updated
      result[:scroll] = scroller.period
    end
    result
  end

  def inspect
    "#<Layer{#{pixels.size}} α=#{layer_opacity} [#{stringify_scroll_period}]>"
  end

  private

  def stringify_scroll_period
    if scroller.period.nil?
      '-0.0-'
    elsif scroller.period > 0
      ">#{scroller.period}>"
    else
      "<#{-scroller.period}<"
    end
  end

end

