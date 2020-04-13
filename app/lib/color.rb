require_relative 'color_tools'
require_relative 'color_a'

class Color
  include ColorTools

  def initialize(red = 0, green = red, blue = green, white = nil, bounded: true)
    if (@bounded = bounded)
      @red, @green, @blue, @white = *cap_comps(red, green, blue, white)
    else
      @red, @green, @blue, @white = red, green, blue, white
    end
  end

  def a!
    ColorA.new(self)
  end

  def c!
    self
  end

  attr_reader :red, :green, :blue, :white, :bounded

  def bound
    Color.new(red, green, blue, white, bounded: true)
  end

  def unbound
    Color.new(red, green, blue, white, bounded: false)
  end

  def +(other)
    Color.new(
        red + other.red,
        green + other.green,
        blue + other.blue,
        (white || 0) + (other.white || 0),
        bounded: bounded
    )
  end

  def -(other)
    Color.new(
        red - other.red,
        green - other.green,
        blue - other.blue,
        (white || 0) - (other.white || 0),
        bounded: bounded
    )
  end

  def *(brightness)
    Color.new *scale_comps(brightness.to_f, red, green, blue, white), bounded: bounded
  end

  def /(dimness)
    Color.new *scale_comps(1 / dimness.to_f, red, green, blue, white), bounded: bounded
  end

  def -@
    (white ? Color.new(255, 255, 255, 255) : Color.new(255, 255, 255)) - self
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
    "#{bounded ? '' : '!'}[#{red},#{green},#{blue}#{white ? ",#{white}" : ''}]"
  end

  alias :inspect :to_s

  def self.from_s(color_string)
    return nil unless color_string && !color_string.empty?
    Color.new *color_string.gsub('!', '')[1..-2].split(',').collect(&:to_i),
              bounded: !(color_string[0] == '!')
  end
end
