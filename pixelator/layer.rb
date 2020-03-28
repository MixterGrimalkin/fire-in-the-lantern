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
    @opacity = 1.0
    @contents = [ColorA.new(default)] * pixel_count
    @scroller = Scroller.new
  end

  attr_accessor :opacity, :pixel_opacity, :contents

  attr_reader :pixels, :scroller

  def pixel_count
    pixels.size
  end

  def color_array
    contents.collect(&:color)
  end

  def alpha_array
    contents.collect(&:alpha)
  end

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, alpha = 1.0)
    raise PixelOutOfRangeError unless (0..(pixel_count-1)).include?(pixel)

    contents[pixel] = ColorA.new(color, alpha)
  end

  def fill(color, alpha = 1.0)
    pixel_count.times do |i|
      contents[i] = ColorA.new(color, alpha)
    end
  end

  def gradient(config)
    @contents = draw_gradient(pixels.size, config)
    self
  end

  def update
    scroller.check_and_update
  end

  def expand(canvas_size)
    result = [ColorA.new] * canvas_size
    contents.each_with_index do |color_a, i|
      result[pixels[i]] = color_a
    end
    result
  end

  def render_over(base_layer)
    buffer = scroller.scroll(expand(base_layer.size))
    buffer.each_with_index do |color_a, i|
      unless color_a.nil? || color_a.color.nil?
        base_layer[i] = color_a.color.blend_over(base_layer[i], color_a.alpha * opacity)
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
        contents: contents,
        opacity: opacity,
    }
    if scroller.last_updated
      result.merge!(
          scroll: scroller.period,
          scroll_over_sample: scroller.over_sample
      )
    end
    result
  end

  def inspect
    "#<Layer{#{pixels.size}} α=#{opacity} [#{stringify_scroll_period}]>"
  end

  private

  def stringify_scroll_period
    if scroller.period.nil?
      '----'
    elsif scroller.period > 0
      "+#{scroller.period}+"
    else
      "-#{-scroller.period}-"
    end
  end

end

