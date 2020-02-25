class Color

  def initialize(red = 0, green = red, blue = green, white = nil)
    [red, green, blue, white].each do |c|
      unless c.nil? || (0..255).include?(c)
        raise ColorValueOutOfRange, "#{red},#{green},#{blue},#{white}"
      end
    end

    @red, @green, @blue, @white = red, green, blue, white
  end

  attr_accessor :red, :green, :blue, :white

  def self.safe(red = 0, green = red, blue = green, white = nil)
    Color.new(
        [[255, red].min, 0].max,
        [[255, green].min, 0].max,
        [[255, blue].min, 0].max,
        white.nil? ? nil : [[255, white].min, 0].max
    )
  end

  def with_brightness(brightness)
    Color.new(
        (red * brightness).floor,
        (green * brightness).floor,
        (blue * brightness).floor,
        white.nil? ? nil : (white * brightness).floor,
    )
  end

  def blend_over(underlay, alpha = 1.0)
    if alpha == 0.0
      underlay
    elsif alpha == 1.0
      self
    else
      w = white || 0
      uw = underlay.white || 0
      Color.new(
          (red + ((1-alpha) * (underlay.red - red))).floor,
          (green + ((1-alpha)* (underlay.green - green))).floor,
          (blue + ((1-alpha) * (underlay.blue - blue))).floor,
          (w + ((1-alpha) * (uw - w))).floor
      )
    end
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

end

class ColorValueOutOfRange < StandardError;
end
