require_relative '../../fitl/color/colors'

class Story
  include Colors

  def initialize(size:, settings: OpenStruct.new)
    @size = size
    @settings = settings
  end

  attr_reader :size, :settings

  def update

  end

  def render_over(base_layer)
    base_layer
  end

end