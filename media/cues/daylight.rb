include Fitl

class Daylight < Cue
  def setup
    build_layer config: { fill: Colour.new(255,255,251) }
  end
end