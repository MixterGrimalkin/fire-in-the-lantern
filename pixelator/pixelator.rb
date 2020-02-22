require_relative 'pixel'
require_relative 'pixel_layer'

class Pixelator

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @pixels = []
    pixel_count.times { |i| @pixels << Pixel.new(i) }
    @layers = {all: PixelLayer.new(@pixels)}
    @started = false
  end

  attr_reader :neo_pixel, :pixels, :started

  def pixel_count
    @neo_pixel.pixel_count
  end

  def start(period = 0.01)
    raise NotAllowed if @started

    @started = true
    Thread.new do
      while @started
        render
        sleep period
      end
    end
  end

  def stop
    raise NotAllowed unless @started

    @started = false
  end

  def render
    pixels.each { |p| neo_pixel.set(p.number, p.get) }
    neo_pixel.render
  end

  def layer(layer_def)
    return unless layer_def.is_a?(Hash) && layer_def.size == 1

    key, criteria = layer_def.first[0], layer_def.first[1]

    layer =
        PixelLayer.new(pixels.select do |p|
          case criteria
            when Range, Array
              criteria.include?(p.number)
            when Proc
              criteria.call p
          end
        end)

    self.class.send(:define_method, key.to_sym, proc { layer })

    @layers[key] = layer
  end

  def []=(key, layer)
    return unless key.is_a?(Symbol) and layer.is_a?(PixelLayer)

    @layers[key] = layer
  end

  def [](key)
    case key
      when Integer
        @pixels[key]
      when Symbol
        @layers[key]
    end
  end

end

NotAllowed = Class.new(StandardError)
