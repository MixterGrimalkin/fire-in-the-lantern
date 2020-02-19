require_relative '../support/color'

class Pixel

  def initialize(number)
    @number = number
    @color = Color.new
    @brightness = 0
  end

  attr_reader :number
  attr_accessor :color, :brightness

  def set(color, brightness = 1.0)
    @color, @brightness = color, brightness
  end

  def get
    Color.new(
             (color.red * brightness).floor,
             (color.green * brightness).floor,
             (color.blue * brightness).floor,
             color.white.nil? ? nil : (color.white * brightness).floor,
    )
  end

end