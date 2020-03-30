require_relative '../lib/color'
require_relative '../lib/color_a'
require_relative '../lib/colors'
require_relative '../lib/color_tools'
require_relative '../lib/errors'
require_relative 'scroller'

class Layer
  include Colors
  include ColorTools

  def initialize(canvas, background: nil, size: nil)
    @canvas = canvas
    @background = background
    @opacity = 1.0
    @layer_scroller = Scroller.new
    @pattern_scroller = Scroller.new
    resize size || canvas.size
  end

  def resize(size)
    @pattern = [ColorA.new(background)] * (size || canvas.size)
  end

  def to_conf
    result = {
        canvas: canvas,
        background: background,
        opacity: opacity,
        pattern: pattern
    }
    if layer_scroller.last_updated
      result.merge!(layer_scroller: layer_scroller.to_conf)
    end
    if pattern_scroller.last_updated
      result.merge!(pattern_scroller: pattern_scroller.to_conf)
    end
    result
  end

  def from_conf(conf)
    @canvas = conf[:canvas]
    @background = conf[:background]
    @opacity = conf[:opacity]
    @pattern = conf[:pattern].collect { |string| ColorA.from_s(string) }
    layer_scroller.from_conf(conf[:layer_scroller]) if conf[:layer_scroller]
    pattern_scroller.from_conf(conf[:pattern_scroller]) if conf[:pattern_scroller]
  end

  attr_accessor :opacity, :pattern, :background

  attr_reader :canvas,
              :layer_scroller, :pattern_scroller

  def color_array
    pattern.collect(&:color)
  end

  def alpha_array
    pattern.collect(&:alpha)
  end

  def ==(other)
    canvas == other.canvas
  end

  def +(other)
    Layer.new(canvas + other.canvas)
  end

  def -(other)
    Layer.new(canvas - other.canvas)
  end

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, alpha = 1.0)
    raise PixelOutOfRangeError unless (0..(pattern.size-1)).include?(pixel)
    pattern[pixel] = ColorA.new(color, alpha)
  end

  def fill(color, alpha = 1.0)
    @pattern = pattern.collect { ColorA.new(color, alpha) }
  end

  def gradient(config)
    @pattern = draw_gradient(pattern.size, config)
    self
  end

  def update
    layer_scroller.check_and_update
    pattern_scroller.check_and_update
  end



  def inspect
    "#<Layer{#{canvas.size}} α=#{opacity} [#{stringify_scroll_period}]>"
  end

  def render_over(base_layer)
    build_buffer(base_layer.size).each_with_index do |color_a, i|
      unless color_a.nil? || color_a.color.nil?
        base_layer[i] = color_a.color.blend_over(base_layer[i], color_a.alpha * opacity)
      end
    end
    base_layer
  end

  private

  def build_buffer(size)
    layer_scroller.scroll(
        expand_content_to_layer(
            chop_pattern(size),
            size
        )
    )
  end

  def chop_pattern(size)
    pattern_scroller.scroll(pattern)[0..size-1]
  end

  def expand_content_to_layer(content, layer_size)
    result = [ColorA.new] * layer_size
    content.each_with_index do |color_a, i|
      result[canvas[i]] = color_a if canvas[i] < layer_size
    end
    result
  end

  def stringify_scroll_period
    if layer_scroller.period.nil?
      '----'
    elsif layer_scroller.period > 0
      "+#{layer_scroller.period}+"
    else
      "-#{-layer_scroller.period}-"
    end
  end

end

