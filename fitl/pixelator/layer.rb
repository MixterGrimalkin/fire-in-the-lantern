require_relative '../color/colors'
require_relative '../lib/errors'

require_relative 'scroller'
require_relative 'fader'

require 'ostruct'

class Layer
  include Colors
  include Utils

  def initialize(size:, name: nil,
                 visible: true, opacity: 1.0, fill: nil,
                 scroller: nil, fader: nil,
                 contents: nil,
                 assets: Assets.new
  )
    @name = name
    @size = size
    @visible = visible
    @opacity = opacity
    @assets = assets

    if contents && contents.size == size
      self.contents = contents.collect do |element|
        case element
          when ColorA
            element
          when String
            ColorA.from_s element
          else
            ColorA.new
        end
      end
    else
      fill(fill)
    end

    @scroller =
        case scroller
          when Scroller
            scroller
          when Hash
            Scroller.new(scroller.merge(size: size, assets: assets))
          else
            Scroller.new(size: size, assets: assets)
        end

    @fader = fader || Fader.new(size: size)
  end

  attr_reader :size, :scroller, :fader
  attr_accessor :visible, :opacity, :name, :contents
  private :contents=

  def resize(new_size)

  end

  # Drawing

  def clear
    fill ColorA.new
  end

  def fill(color, alpha = 1.0)
    self.contents = [ColorA.cast(color, alpha)] * size
  end

  def [](pixel)
    check_pixel_number! pixel
    contents[pixel]
  end

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, alpha = 1.0)
    check_pixel_number! pixel
    contents[pixel] = ColorA.cast(color, alpha)
  end

  def draw(pattern, start = 0)
    pattern.each_with_index do |entry, i|
      if check_pixel_number(start + i)
        contents[start + i] = ColorA.cast(entry)
      end
    end
  end

  # Visibility

  def show
    self.visible = true
  end

  def hide
    self.visible = false
  end

  # Contents

  def to_a
    contents
  end

  def color_array
    contents.collect(&:color)
  end

  def alpha_array
    contents.collect(&:alpha)
  end

  # Scroller

  def scroll(period = nil, oversample = nil)
    scroller.period = period if period
    scroller.oversample = oversample if oversample
    scroller.start
  end

  def stop_scroll
    scroller.stop
  end

  # Fader

  def fade_in(time = 0, min: 0, max: 1, bounce: false)
    fade time, start: min, target: max, bounce: bounce
  end

  def fade_out(time = 0, min: 0, max: 1, bounce: false)
    fade time, start: max, target: min, bounce: bounce
  end

  def fade(time, start:, target:, bounce: false)
    fader.fade time, start: start, target: target, bounce: bounce
  end

  # Save

  def to_h
    {
        name: name,
        size: size,
        visible: visible,
        opacity: opacity,
        scroller: scroller.to_h,
        contents: contents.collect(&:to_s)
    }
  end

  def inspect
    vis = visible ? '✔' : '✗'
    sze = colorize(size, bold: true)
    scr = "δ=#{scroller}"
    fdr = "Φ=#{fader}"
    opa = "α=#{opacity}"
    "<Layer:#{name}[#{vis}] #{sze} #{scr} #{fdr} #{opa}>"
  end

  # Update and Render

  def update
    return unless visible

    scroller.check_and_update
    fader.check_and_update
  end

  def render_over(base_layer, canvas: nil, alpha: 1.0)
    return base_layer unless visible && alpha > 0.0
    canvas = (canvas || default_canvas).to_a
    result = []
    expand_content(base_layer.size, canvas).each_with_index do |color_a, i|
      result[i] =
          if color_a.nil?
            base_layer[i]
          else
            color_a.blend_over(base_layer[i], opacity * alpha)
          end
    end
    result
  end

  private

  def expand_content(view_size, canvas)
    result = [nil] * view_size
    chop_pattern(canvas).each_with_index do |color_a, i|
      result[canvas[i]] = color_a if canvas[i] < view_size
    end
    result
  end

  def chop_pattern(canvas)
    scroller.apply(
        fader.apply(
            contents
        )
    )[0..canvas.size-1]
  end

  def default_canvas
    @default_canvas ||= (0..(size-1)).to_a
  end

  def check_pixel_number(pixel)
    0 <= pixel && pixel < size
  end

  def check_pixel_number!(pixel)
    raise PixelOutOfRangeError, pixel unless check_pixel_number(pixel)
  end
end
