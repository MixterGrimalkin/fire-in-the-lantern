include Fitl

class LanternOne < Cue

  CANDLE_BACK = (0..3)
  CANDLE_FRONT = (4..7)
  CANDLE = (0..7)
  LOWER_RING = (8..17)
  UPPER_RING = (18..34)
  BOTH_RINGS = LOWER_RING.to_a + UPPER_RING.to_a

  SWIRL_LEAD = (WHITE * 0.5).override(alpha: 0.7)
  SWIRL_UPPER = Colour.new 90, 45, 0 , alpha: 0.6
  SWIRL_LOWER = Colour.new 100, 40, 0, alpha: 0.6

  SWIRL_PERIOD = 0.08
  SWIRL_SIZE = 35
  SWIRL_SPACER = 250
  SWIRL_OVERSAMPLE = 6
  UPPER_SWIRL_LEAD_COLOR = SWIRL_LEAD
  UPPER_SWIRL_TAIL_COLOR = SWIRL_UPPER
  LOWER_SWIRL_LEAD_COLOR = SWIRL_LEAD
  LOWER_SWIRL_TAIL_COLOR = SWIRL_LOWER
  SWIRL_OPACITY = 0.67

  FADE_1 = ORANGE.adjust(red:7)
  FADE_2 = INDIGO
  FADE_3 = RED.adjust(blue: 30)

  UPPER_FADE_COLORS = [FADE_1, FADE_2, FADE_1, FADE_1, FADE_3]
  LOWER_FADE_COLORS = [FADE_2, FADE_1, FADE_1, FADE_3, FADE_1]
  FADE_PERIOD = 30
  FADE_OPACITY = 0.95

  def setup
    build_layer(
        FadeLayer,
        config: {
            colors: LOWER_FADE_COLORS,
            period: FADE_PERIOD
        },
        canvas: LOWER_RING
    ).opacity = FADE_OPACITY

    build_layer(
        FadeLayer,
        config: {
            colors: UPPER_FADE_COLORS,
            period: FADE_PERIOD
        },
        canvas: UPPER_RING
    ).opacity = FADE_OPACITY

    build_layer(
        GradientLayer,
        config: {
            size: UPPER_RING.size + SWIRL_SPACER,
            gradient_size: SWIRL_SIZE,
            to: UPPER_SWIRL_LEAD_COLOR,
            from: UPPER_SWIRL_TAIL_COLOR,
            sym: false,
            offset: 0
        },
        canvas: UPPER_RING
    ).scroll(SWIRL_PERIOD, SWIRL_OVERSAMPLE).opacity = SWIRL_OPACITY

    build_layer(
        GradientLayer,
        config: {
            size: UPPER_RING.size + SWIRL_SPACER,
            gradient_size: SWIRL_SIZE,
            to: LOWER_SWIRL_LEAD_COLOR,
            from: LOWER_SWIRL_TAIL_COLOR,
            sym: false,
            offset: 0
        },
        canvas: LOWER_RING
    ).scroll(SWIRL_PERIOD, SWIRL_OVERSAMPLE).opacity = SWIRL_OPACITY
  end
end
