include Fitl

class LanternTwo < Cue

  OUTER_RING = (0..23)
  INNER_RING = (24..35)
  TOP_STRIP = (36..45)

  FADE_1 = ORANGE.adjust(red:70, green: -20)
  FADE_2 = INDIGO.adjust(blue: -30)
  FADE_3 = RED.adjust(blue: 10)

  # FADE_1 = Colour.new 130, 240, 200
  # FADE_2 = Colour.new 230, 50, 20
  # FADE_3 = RED.adjust(blue: 10)

  TOP_COLOURS =   [
      FADE_1, FADE_2, FADE_1, FADE_1, FADE_3
  ]

  OUTER_COLOURS = [
      FADE_2, FADE_1, FADE_1, FADE_3, FADE_1
  ]
  INNER_COLOURS = [
      FADE_1, FADE_2, FADE_1, FADE_1, FADE_3
  ]

  FADE_PERIOD = 20

  SCROLL = 0.5

  def setup
    build_layer(
        FadeLayer,
        config: {
            colors: TOP_COLOURS,
            period: FADE_PERIOD
        },
        canvas: TOP_STRIP
    ).opacity = 1.2

    build_layer(
        FadeLayer,
        config: {
            colors: OUTER_COLOURS,
            period: FADE_PERIOD
        },
        canvas: OUTER_RING
    ).opacity = 0.1

  build_layer(
        FadeLayer,
        config: {
            colors: INNER_COLOURS,
            period: FADE_PERIOD
        },
        canvas: INNER_RING
    ).opacity = 0.25
  end
end