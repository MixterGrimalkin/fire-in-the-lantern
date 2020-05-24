class Color
  def initialize(red = 0, green = red, blue = red, white = 0)
    @real_red, @real_green, @real_blue, @real_white = red, green, blue, white
  end

  attr_reader :real_red, :real_green, :real_blue, :real_white

  def red
    @red ||= crop_component(real_red)
  end

  def green
    @green ||= crop_component(real_green)
  end

  def blue
    @blue ||= crop_component(real_blue)
  end

  def white
    @white ||= crop_component(real_white)
  end

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
    Color.new *scale_components(brightness.to_f, real_red, real_green, real_blue, real_white)
  end

  def /(dimness)
    Color.new *scale_components(1 / dimness.to_f, real_red, real_green, real_blue, real_white)
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
    Color.blend(underlay, self, alpha)
  end

  def blend_under(overlay, alpha = 1.0)
    Color.blend(self, overlay, alpha)
  end

  class << self

    def blend(under, over, alpha = 1.0)
      if under.nil? || alpha == 1.0
        over
      elsif over.nil? || alpha == 0.0
        under
      else
        under + ((over - under) * alpha)
      end
    end

    def blend_range(under, over, alpha = 1.0)
      raise BlendRangeMismatch unless under.size==over.size

      if alpha == 1.0
        over
      elsif alpha == 0.0
        under
      else
        result = []
        over.size.times do |i|
          result << blend(under[i], over[i], alpha)
        end
        result
      end
    end

    def from_s(color_string)
      return nil unless color_string && !color_string.empty?
      Color.new *color_string[1..-2].split(',').collect(&:to_i)
    end

  end

  def to_s
    "[#{red},#{green},#{blue},#{white}]"
  end

  alias :inspect :to_s

  BlendRangeMismatch = Class.new(StandardError)

  MAX = 255

  private

  def crop_component(comp)
    [0, [MAX, comp.to_i].min].max
  end

  def scale_components(scale, r, g, b, w)
    [r, g, b, w].collect { |c| (c * scale).floor }
  end

end

