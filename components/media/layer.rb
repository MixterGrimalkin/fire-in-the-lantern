require './components/modifiers/scroller'
require './components/assets'
require './lib/colours'
require './lib/utils'

module Fitl
  class Layer
    include Colours
    include Utils

    def initialize(
        size:,
        name: 'Layer',
        visible: true,
        opacity: 1.0,
        fill: EMPTY,
        scroller: nil,
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
            when Colour
              element
            when String
              Colour.from_s element
            else
              EMPTY
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
    end

    attr_reader :size, :scroller
    attr_accessor :visible, :opacity, :name, :contents
    private :contents=

    # Drawing

    def clear
      fill EMPTY
    end

    def fill(colour)
      self.contents = [colour] * size
    end

    def [](pixel)
      check_pixel_number! pixel
      contents[pixel]
    end

    def []=(pixel, colour)
      check_pixel_number! pixel
      contents[pixel] = colour
    end

    def draw(pattern, start = 0)
      pattern.each_with_index do |entry, i|
        if check_pixel_number(start + i)
          contents[start + i] = entry
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
      contents.collect(&:components)
    end

    def alpha_array
      contents.collect(&:alpha)
    end

    # Scroller

    def scroll(period = nil, oversample = nil)
      scroller.period = period if period
      scroller.oversample = oversample if oversample
      scroller.start
      self
    end

    def stop_scroll
      scroller.stop
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
      opa = "α=#{opacity}"
      "<Layer:#{name}[#{vis}] #{sze} #{scr} #{opa}>"
    end

    # Update and Render

    def update
      return unless visible

      scroller.check_and_update
    end

    def render_over(base_layer, canvas: nil, alpha: 1.0)
      return base_layer unless visible && alpha > 0.0
      canvas = canvas&.to_a || default_canvas
      result = []
      expand_content(base_layer.size, canvas).each_with_index do |colour, i|
        result[i] =
            if colour.nil? || colour.alpha == 0.0
              base_layer[i]
            else
              colour.blend_over(base_layer[i], opacity * alpha)
            end
      end
      result
    end

    private

    def expand_content(view_size, canvas)
      result = [nil] * view_size
      chop_pattern(canvas).each_with_index do |colour, i|
        result[canvas[i]] = colour if canvas[i] < view_size
      end
      result
    end

    def chop_pattern(canvas)
      scroller.apply(contents)[0..canvas.size-1]
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

    PixelOutOfRangeError = Class.new(StandardError)
  end
end
