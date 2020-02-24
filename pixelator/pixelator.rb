require_relative '../support/color'
require_relative '../support/color_constants'
require_relative 'pixel'
require_relative 'pixel_layer'

require 'byebug'

class Pixelator
  include ColorConstants

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @pixels = []
    pixel_count.times { |i| @pixels << i }
    @layers = {}
    layer(:base, BLACK)
    @started = false
    @render_thread = nil
  end

  attr_reader :neo_pixel, :pixels, :started, :layers

  def pixel_count
    @neo_pixel.pixel_count
  end

  def clear
    @layers = {}
    layer(:base, BLACK)
    render
  end

  def start(period = 0.01)
    raise NotAllowed if @started

    @started = true

    @render_thread = Thread.new do
      while @started
        @layers.values.each(&:update)
        render
        sleep period
      end
    end
  end

  def stop
    raise NotAllowed unless @started

    @started = false
    @render_thread.join
  end


  def render
    neo_pixel.contents = build_buffer
    neo_pixel.render
  end

  def build_buffer
    buffer = [BLACK] * pixel_count
    @layers.each do |_, layer|
      buffer = layer.render_over buffer
    end
    buffer
  end

  def all_on
    stop if started
    neo_pixel.all_on
  end

  def all_off
    stop if started
    neo_pixel.all_off
  end

  def layer(layer_def, default = nil)
    if layer_def.is_a? Symbol
      key = layer_def
      layer = PixelLayer.new(pixels, default)

    elsif layer_def.is_a?(Hash) && layer_def.size==1
      key, criteria = layer_def.first[0], layer_def.first[1]
      layer =
          PixelLayer.new(pixels.select do |p|
            case criteria
              when Range, Array
                criteria.include?(p)
              when Proc
                criteria.call p
            end
          end, default)

    else
      return
    end

    self.class.send(:define_method, key.to_sym, proc { layer })
    @layers[key] = layer
  end

  def []=(key, value)
    case key
      when Integer
        return unless value.is_a? Color
        @layers[:base][key] = value
      when Symbol
        return unless value.is_a? PixelLayer
        @layers[key] = value
      else
        nil
    end
  end

  def [](key)
    case key
      when Integer
        @layers[:base][key]
      when Symbol
        @layers[key]
      else
        nil
    end
  end

end

NotAllowed = Class.new(StandardError)