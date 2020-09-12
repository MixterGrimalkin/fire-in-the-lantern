class LanternOne < Cue
  include Colors

  def initialize(size:, assets: Assets.new)
    super(name: 'Lantern One', size: size, assets: assets)
    reset
  end

  CANDLE_BACK = (0..3)
  CANDLE_FRONT = (4..7)
  CANDLE = (0..7)
  LOWER_RING = (8..17)
  UPPER_RING = (18..34)

  def reset
    reset_layers

    build_layer(GradientLayer,
                canvas: UPPER_RING,
                config: {
                    name: 'red_grad',
                    size: 60,
                    from: RED,
                    to: BLACK,
                    sym: false
                }
    ).scroll -0.05, 10

    build_layer(GradientLayer,
                canvas: UPPER_RING,
                config: {
                    name: 'yellow_grad',
                    size: 90,
                    from: BLACK,
                    to: YELLOW,
                    sym: false
                }
    ).scroll 0.08, 10
    layer(:yellow_grad).opacity = 0.5

    build_layer(GradientLayer,
                canvas: CANDLE,
                config: {
                    size: 20,
                    from: RED,
                    to: ORANGE,
                    sym: true
                }
    ).scroll 0.2, 10

    build_layer(FadeLayer,
                canvas: LOWER_RING,
                config: {
                    colors: [BLUE * 0.8, GREEN * 0.6],
                    period: 2
                })
  end

end
