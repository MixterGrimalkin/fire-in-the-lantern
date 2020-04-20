require_relative '../lib/color'
require_relative '../lib/color_a'
require_relative '../lib/colors'
require_relative '../lib/color_tools'
require_relative '../lib/errors'
require_relative 'layer_config'
require_relative 'scroller'
require_relative 'modifiers'

class Layer
  include LayerConfig
  include Colors
  include ColorTools

  def initialize(canvas, background: nil, size: nil, settings: OpenStruct.new)
    @settings = settings
    @canvas = canvas
    @background = background
    @opacity = 1.0
    @visible = true
    @layer_scroller = Scroller.new settings: settings
    @pattern_scroller = Scroller.new settings: settings
    resize size || canvas.size
  end

  def resize(size)
    @pattern = [ColorA.new(background)] * (size || canvas.size)
    @modifiers = Modifiers.new pattern.size
  end

  attr_accessor :opacity

  attr_reader :canvas, :visible, :pattern, :background,
              :layer_scroller, :pattern_scroller, :modifiers

  def color_array
    pattern.collect(&:color)
  end

  def alpha_array
    pattern.collect(&:alpha)
  end

  def hide
    @visible = false
  end

  def show
    @visible = true
  end

  def [](pixel)
    check_pixel_number pixel
    pattern[pixel]
  end

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, alpha = 1.0)
    check_pixel_number pixel
    pattern[pixel] = ColorA.new(color, alpha)
  end

  def set_range(range, color, alpha = 1.0)
    range.each do |pixel|
      set(pixel, color, alpha)
    end
  end

  def fill(color, alpha = 1.0)
    @pattern = pattern.collect { ColorA.new(color, alpha) }
  end

  def gradient(config)
    @pattern = draw_gradient(pattern.size, config)
    self
  end

  def inspect
    "#<Layer(#{canvas.size}/#{pattern.size})#{visible ? '⭘' : '⭙'}  α=#{opacity} δl=#{layer_scroller} δp=#{pattern_scroller}>"
  end

  def fade_in(time = 0, min: 0, max: 1, bounce: false)
    fade time, start: min, target: max, bounce: bounce
  end

  def fade_out(time = 0, min: 0, max: 1, bounce: false)
    fade time, start: max, target: min, bounce: bounce
  end

  def fade(time, start:, target:, bounce: false)
    modifiers.fade time, start: start, target: target, bounce: bounce
  end

  def update
    layer_scroller.check_and_update
    pattern_scroller.check_and_update
    modifiers.check_and_update
  end

  def render_over(base_layer, alpha: 1.0)
    return base_layer unless visible

    build_buffer(base_layer.size).each_with_index do |color_a, i|
      unless color_a.nil? || color_a.color.nil?
        base_layer[i] = color_a.color.blend_over(base_layer[i], color_a.alpha * opacity * alpha)
      end
    end
    base_layer
  end

  private

  def build_buffer(size)
    layer_scroller.scroll(expand_content size)
  end

  def expand_content(size)
    result = [ColorA.new] * size
    chop_pattern.each_with_index do |color_a, i|
      result[canvas[i]] = color_a if canvas[i] < size
    end
    result
  end

  def chop_pattern
    pattern_scroller.scroll(
        modifiers.apply(pattern)
    )[0..canvas.size-1]
  end

  def check_pixel_number(pixel)
    raise PixelOutOfRangeError, pixel unless (0..(pattern.size-1)).include?(pixel)
  end

  attr_reader :settings
end
