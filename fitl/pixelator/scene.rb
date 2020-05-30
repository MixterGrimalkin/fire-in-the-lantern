require_relative '../color/colors'
require_relative 'layer'
require_relative 'cue'

require 'forwardable'

class Scene
  include Colors
  extend Forwardable

  def initialize(size:, assets: Assets.new)
    @pixels = (0..(size-1)).to_a
    @assets = assets
    # @selected_cue = nil
    # clear
  end

  def clear
    @cues = {}
  end

  def new_cue(name)

  end

  def cue
    selected_cue ||= :default



    return cues[selected_cue] if selected_cue

    cue[selected_cue = :default] ||= Cue.new(pixels, assets)
  end

  attr_reader :pixels, :cues

  def_delegators :cue,
                 :hide_all, :show_all, :solo, :put_top, :put_bottom,
                 :[], :[]=, :layer, :layers, :base

  def method_missing(name, *_args, &_block)
    raise LayerNotFound unless cue.layers[name]

    layers[name]
  end

  def render_over(base_layer)
    base_layer
  end

  def update
    # cue.update
  end

  def build_buffer
    cue.build_buffer
  end

  private

  attr_reader :assets
end
