require_relative '../../fitl/color/colors'

class Story
  include Colors

  def initialize(size:, assets: Assets.new)
    @size = size
    @assets = assets
  end

  attr_reader :size, :assets

  def update

  end

  def render_over(base_layer)
    base_layer
  end

end