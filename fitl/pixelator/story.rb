require_relative '../../fitl/color/colors'

class Story
  include Colors

  def initialize(size:, name:, assets: Assets.new)
    @size = size
    @name = name
    @assets = assets
  end

  attr_reader :size, :assets
  attr_accessor :name

  def update

  end

  def render_over(base_layer)
    base_layer
  end

end