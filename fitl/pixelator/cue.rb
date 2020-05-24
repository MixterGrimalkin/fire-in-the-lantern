require_relative '../lib/colors'
require_relative 'cue_config'
require_relative 'layer'

class Cue
  include CueConfig
  include Colors

  def initialize(pixels, settings: OpenStruct.new)
    @pixels = pixels
    @settings = settings
    clear
  end

  def clear
    @layers = {}
    layer(:base, background: BLACK)
  end

  attr_reader :pixels, :layers

  def hide_all
    layers.values.each(&:hide)
  end

  def show_all
    layers.values.each(&:show)
  end

  def solo(layer_key)
    raise LayerNotFound, layer_key unless layers[layer_key]
    hide_all
    layers[layer_key].show
  end

  def update
    layers.values.each(&:update)
  end

  def put_top(layer_key)
    raise LayerNotFound, layer_key unless layers[layer_key]

    new_layers = {}
    layers.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    new_layers[layer_key] = layers[layer_key]
    @layers = new_layers
  end

  def put_bottom(layer_key)
    raise LayerNotFound, layer_key unless layers[layer_key]

    new_layers = {layer_key => layers[layer_key]}
    layers.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    @layers = new_layers
  end

  def build_buffer
    render_over [BLACK]*pixels.size
  end

  def render_over(base_layer, alpha: 1.0)
    layers.values.inject(base_layer) do |buffer, layer|
      layer.render_over buffer, alpha: alpha
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

  def []=(key, value)
    case key
      when Integer
        return unless value.is_a? Color
        @layers[:base][key] = value
      when Symbol
        return unless value.is_a? Layer
        @layers[key] = value
      else
        nil
    end
  end

  def layer(key, canvas: nil, size: nil, background: nil)
    if canvas.nil?
      layer = Layer.new(pixels, size: size, background: background, settings: settings)
    else
      layer =
          Layer.new(pixels.select do |p|
            case canvas
              when Range, Array
                canvas.include?(p)
              when Proc
                canvas.call p
            end
          end, size: size, background: background, settings: settings)
    end

    self.class.send(:define_method, key, proc { layer })
    layers[key] = layer
  end

  private

  attr_reader :settings
end

LayerNotFound = Class.new(StandardError)