require_relative 'color'

class ColorA

  def initialize(color = nil, alpha = 1.0)
    @color = color
    @alpha = alpha
  end

  attr_accessor :color, :alpha

  def ==(other)
    color == other.color && alpha == other.alpha
  end

end