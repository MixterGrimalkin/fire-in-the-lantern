require_relative 'color'
require_relative 'color_a'
require_relative 'tools'

module Colors

  RGB = [:red, :green, :blue]
  RGBW = RGB + [:white]
  RGBW_A = RGBW + [:alpha]

  BLACK = Color.new
  WHITE = Color.new 255

  WARM_WHITE = Color.new 0, 0, 0, 255
  FULL_WHITE = Color.new 255, 255, 255, 255

  RED = Color.new 255, 0, 0
  GREEN = Color.new 0, 255, 0
  BLUE = Color.new 0, 0, 255

  YELLOW = Color.new 255, 255, 0
  MAGENTA = Color.new 255, 0, 255
  CYAN = Color.new 0, 255, 255

  ORANGE = Color.new 255, 170, 0
  INDIGO = Color.new 160, 0, 255
  VIOLET = Color.new 255, 0, 160

  EMPTY = ColorA.new
  BLACKOUT = ColorA.new Color.new

end
