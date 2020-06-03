require_relative '../color/colors'
require_relative 'cue_config'
require_relative 'layer'

class Cue
  include CueConfig
  include Colors

  def initialize(size: nil, name: nil, layer_reg: [], assets: Assets.new)
    @size = size || assets.pixel_count
    @name = name
    @playing = false
    @assets = assets
    clear

    layer_reg.each do |entry|
      if (name = entry[:from_file])
        link_layer name, canvas: entry[:canvas]
      else
        build_layer entry[:layer_def], canvas: entry[:canvas]
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
    wait_for 1
    # Your code here
  end

  def clear
    self.layer_register = {}
  end

  def build_layer(config, canvas = nil)
    add_layer assets.build_layer(config), canvas, external: false
  end

  def link_layer(name, canvas = nil)
    add_layer assets.load_layer(name), canvas, external: true
  end

  def add_layer(layer, canvas = nil, external: false)
    layer_register[layer.name.to_sym] = {
        layer: layer,
        canvas: canvas,
        external: external
    }
  end

  def layers
    layer_register.values.collect { |entry| entry[:layer] }
  end

  def layer(key)
    check_layer! key
    layer_register[key][:layer]
  end

  def link_out(key)
    check_layer! key, false
    entry = layer_register[key]
    assets.save_layer entry[:layer].name, entry[:layer]
    entry[:external] = true
  end

  def copy_in(key)
    check_layer! key, true
    layer_register[key][:external] = false
  end

  def apply_canvas(layer_key, canvas = nil)
    layers[layer_key][:canvas] = canvas
  end

  def to_h
    {
        name: name,
        size: size,
        layer_reg: layer_register.collect do |_key, entry|
          if entry[:external]
            {from_file: entry[:layer].name}
          else
            {layer_def: entry[:layer].to_h}
          end.merge(canvas: entry[:canvas])
        end
    }
  end

  def self.from_h(hash)
    cue = Cue.new size: hash.fetch(:size), name: hash.fetch(:name)
    hash[:layers].each do |entry|
      if (name = entry[:from_file])
        cue.link_layer name, canvas: entry[:canvas]
      else
        cue.build_layer entry[:layer_def], canvas: entry[:canvas]
      end
    end
    cue
  end

  attr_reader :size

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

    layers.each(&:update)
  end

  def put_top(layer_key)
    check_layer! layer_key

    new_layers = {}
    layer_register.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    new_layers[layer_key] = layers[layer_key]
    self.layer_register = new_layers
  end

  def put_bottom(layer_key)
    check_layer! layer_key

    new_layers = {layer_key => layers[layer_key]}
    layer_register.each do |key, layer|
      new_layers[key] = layer unless key==layer_key
    end
    self.layer_register = new_layers
  end

  def render_over(base_layer, alpha: 1.0)
    return base_layer unless playing?

    layer_register.each do |_key, entry|
      base_layer = entry[:layer].render_over(base_layer, canvas: entry[:canvas], alpha: alpha)
    end
    base_layer
  end

  private

  def check_layer(key, external = nil)
    return false unless layer_register[key]

    external.nil? || layer_register[key][:external]
  end

  def check_layer!(key, external = nil)
    raise LayerNotFound, "#{key.to_s}#{
    if external.nil?
      ''
    else
      "#{external ? ':linked' : ':embedded'}"
    end}" unless check_layer(key, external)
  end

  attr_reader :assets
  attr_accessor :layer_register
end

LayerNotFound = Class.new(StandardError)