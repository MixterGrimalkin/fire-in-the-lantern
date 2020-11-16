include Fitl

class Sunset < Cue

  LOWER_RING = (0..9)
  UPPER_RING = (10..26)
  BOTH_RINGS = LOWER_RING.to_a + UPPER_RING.to_a

  FADE_1 = Colour.new(255,150,0)
  FADE_2 = Colour.new(255,100,0)
  FADE_3 = Colour.new(255,190,0)

  def setup
    build_layer(
        FadeLayer,
        config: {
            colors: [FADE_1, FADE_3],
            period: 60
        },
        canvas: LOWER_RING
    )
    build_layer(
        FadeLayer,
        config: {
            colors: [FADE_2, FADE_1],
            period: 60
        },
        canvas: UPPER_RING
    )
  end
end