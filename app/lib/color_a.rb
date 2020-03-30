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

  def to_s
    "(#{color.to_s}x#{alpha})"
  end
  alias :inspect :to_s

  def self.from_s(color_a_string)
    return nil unless color_a_string && !color_a_string.empty?
    comps = color_a_string[1..-2].split('x')
    ColorA.new Color.from_s(comps[0]), comps[1].to_f
  end
end
