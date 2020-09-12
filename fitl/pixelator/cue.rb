require_relative '../color/colors'
require_relative 'layer'
require_relative 'layer_set'

class Cue
  include Colors
  include LayerSet

  def initialize(size: nil, name: nil, assets: Assets.new)
    @size = size || assets.pixel_count
    @name = name
    @playing = false
    @assets = assets
    clear
  end

  def clear
    reset_layers
  end

  def playing?
    @playing
  end

  attr_accessor :name

  # Play

  def play
    return if playing?

    self.playing = true
  end

  def stop
    return unless playing?

    self.playing = false
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

  attr_reader :size

  def update
    return unless playing?

    layers.each(&:update)
  end

  def render_over(base_layer, alpha: 1.0)
    return base_layer unless (playing? && alpha > 0)

    layer_register.each do |_key, entry|
      base_layer = entry[:layer].render_over(base_layer, canvas: entry[:canvas], alpha: alpha)
    end
    base_layer
  end

  attr_reader :assets
  attr_writer :playing
  attr_accessor :play_thread

end
