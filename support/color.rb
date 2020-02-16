class Color

  def initialize(red = 0, green = red, blue = green, white = nil)
    @red, @green, @blue, @white = red, green, blue, white
  end

  attr_accessor :red, :green, :blue, :white

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
