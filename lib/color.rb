require_relative 'color_tools'

class Color
  include ColorTools

  def initialize(red = 0, green = red, blue = green, white = nil)
    @red, @green, @blue, @white = *cap_comps(red, green, blue, white)
  end

  attr_accessor :red, :green, :blue, :white

  def with_brightness(brightness)
    Color.new *scale_comps(brightness, red, green, blue, white)
  end

  def blend_over(underlay, alpha = 1.0)
    blend(underlay, self, alpha)
  end

  def blend_under(overlay, alpha = 1.0)
    blend(self, overlay, alpha)
  end

  def ==(other)
    red == other.red &&
        green == other.green &&
        blue == other.blue &&
        (white.nil? || other.white.nil? || white == other.white)
  end

  def to_s
    "[#{red},#{green},#{blue}#{white ? ",#{white}" : ''}]"
  end
  alias :inspect :to_s

  def self.from_s(color_string)
    Color.new *color_string[1..-2].split(',').collect(&:to_i)
  end
end
