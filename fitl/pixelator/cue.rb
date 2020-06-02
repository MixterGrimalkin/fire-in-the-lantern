require_relative '../color/colors'
require_relative 'cue_config'
require_relative 'layer'

class Cue
  include CueConfig
  include Colors

  def initialize(size: nil, name: nil, layer_defs: [], assets: Assets.new)
    @size = size || assets.pixel_count
    @name = name
    @playing = false
    @assets = assets

    clear

    layer_defs.each do |layer_def|
      if layer_def.is_a? Layer
        add_layer layer_def
      elsif (conf = layer_def[:layer_conf])
        build_layer conf, layer_def[:canvas]
      elsif layer_def[:from_file]
        link_layer layer_def[:name]
      else
        # wtf?
      end
    end
  end

  def playing?
    @playing
  end

  attr_accessor :name

  attr_accessor :play_thread
  private :play_thread, :play_thread=

  attr_writer :playing
  private :playing=

  def play
    return if playing?

    self.playing = true

    self.play_thread = Thread.new do
      while playing?
        playing
      end
    end
  end

  def wait_for(seconds)
    elapsed = 0.0
    while playing? && elapsed < seconds
      sleep 1
      elapsed += 1
    end
  end

  def stop
    return unless playing?

    self.playing = false
  end

  def playing
    sleep 1
    # Your code here
  end

  def clear
    @layers = {}
  end

  def build_layer(config, canvas = nil)
    add_layer assets.build_layer(config), canvas, type: :embedded
  end

  def link_layer(name, canvas = nil)
    add_layer assets.load_layer(name), canvas, type: :linked
  end

  def add_layer(layer, canvas = nil, type: :embedded)
    layers[(layer.name || 'layer').to_sym] = {
        layer: layer,
        canvas: canvas,
        type: type
    }
  end

  def apply_canvas(layer_key, canvas = nil)
    layers[layer_key][:canvas] = canvas
  end

  def to_h
    {
        name: name,
        size: size,
        layers: [
            layers.collect do |key, entry|
              case entry[:type]
                when :embedded
                  {
                      name: entry.layer.name,
                      canvas: entry.canvas,
                      layer_conf: entry.layer.to_h
                  }
                when :linked
                  {
                      name: entry.layer.name,
                      canvas: entry.canvas,
                      from_file: true
                  }
                else
                  # ignored
              end
            end
        ]
    }
  end

  def self.from_h(hash)

  end

  attr_reader :size, :layers

  def hide_all
    layers.values.each(&:hide)
  end

  def show_all
    layers.values.each(&:show)
  end

  def solo(layer_key)
    check_layer! layer_key
    hide_all
    layers[layer_key].show
  end

  def update
    return unless playing?

    layers.each do |_, entry|
      entry[:layer].update
    end
  end

  def put_top(layer_key)
    check_layer! layer_key

    new_layers = {}
    layers.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    new_layers[layer_key] = layers[layer_key]
    @layers = new_layers
  end

  def put_bottom(layer_key)
    check_layer! layer_key

    new_layers = {layer_key => layers[layer_key]}
    layers.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    @layers = new_layers
  end

  def render_over(base_layer, alpha: 1.0)
    return base_layer unless playing?

    layers.each do |key, layer_def|
      base_layer = layer_def[:layer].render_over(base_layer, canvas: layer_def[:canvas], alpha: alpha)
    end
    base_layer
  end

  private

  def check_layer(key)
    !layers[key].nil?
  end

  def check_layer!(key)
    raise LayerNotFound, key.to_s unless check_layer(key)
  end

  attr_reader :assets
end

LayerNotFound = Class.new(StandardError)