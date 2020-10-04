require './lib/colour'

module Fitl
  module Colours
    RGB = [:red, :green, :blue]
    RGBW = RGB + [:white]
    RGBW_A = RGBW + [:alpha]

    BLACK = Colour.new
    WHITE = Colour.new 255

    WARM_WHITE = Colour.new 0, 0, 0, 255
    FULL_WHITE = Colour.new 255, 255, 255, 255

    RED = Colour.new 255, 0, 0
    GREEN = Colour.new 0, 255, 0
    BLUE = Colour.new 0, 0, 255

    YELLOW = Colour.new 255, 255, 0
    MAGENTA = Colour.new 255, 0, 255
    CYAN = Colour.new 0, 255, 255

    ORANGE = Colour.new 255, 170, 0
    INDIGO = Colour.new 160, 0, 255
    VIOLET = Colour.new 255, 0, 160

    EMPTY = Colour.new alpha: 0.0
  end
end