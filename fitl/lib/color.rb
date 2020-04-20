require_relative 'color_tools'
require_relative 'color_a'

class Color
  include ColorTools

  def initialize(red = 0, green = red, blue = red, white = 0)
    @red, @green, @blue, @white = *cap_comps(red, green, blue, white)
    @real_red, @real_green, @real_blue, @real_white = red, green, blue, white
  end

  attr_reader :red, :green, :blue, :white,
              :real_red, :real_green, :real_blue, :real_white

  def +(other)
    Color.new(
        real_red + other.real_red,
        real_green + other.real_green,
        real_blue + other.real_blue,
        real_white + other.real_white
    )
  end

  def -(other)
    Color.new(
        real_red - other.real_red,
        real_green - other.real_green,
        real_blue - other.real_blue,
        real_white - other.real_white
    )
  end

  def *(brightness)
    Color.new *scale_comps(brightness.to_f, real_red, real_green, real_blue, real_white)
  end

  def /(dimness)
    Color.new *scale_comps(1 / dimness.to_f, real_red, real_green, real_blue, real_white)
  end

  def -@
    Color.new(255, 255, 255, 255) - self
  end

  def ==(other)
    red == other.red &&
        green == other.green &&
        blue == other.blue &&
        white == other.white
  end

  def blend_over(underlay, alpha = 1.0)
    blend(underlay, self, alpha)
  end

  def blend_under(overlay, alpha = 1.0)
    blend(self, overlay, alpha)
  end

  def to_s
    "[#{red},#{green},#{blue},#{white}]"
  end

  alias :inspect :to_s

  def self.from_s(color_string)
    return nil unless color_string && !color_string.empty?
    Color.new *color_string[1..-2].split(',').collect(&:to_i)
  end

end
