class FadeLayer < Layer
  def initialize(
    name: 'fade_',
    size:,
    colors: [RED, BLUE],
    period: 3,
    assets: Assets.new
  )
    super(name: name, size: size, assets: assets)

    @colors = colors
    while @colors.size < 2
      @colors << BLACK
    end

    @period = case period
                when Numeric
                  [period] * @colors.size
                when Array
                  period
              end
    while @period.size < @colors.size
      @period << 1
    end

    @color_index = 1
    @started_last_index = Time.now

    fill nil
  end

  attr_accessor :started_last_index, :period, :colors, :color_index

  def update
    return unless visible

    elapsed = (Time.now - started_last_index) / period[color_index].to_f

    if elapsed > 1
      self.color_index = (color_index + 1) % colors.size
      self.started_last_index = Time.now
      elapsed = 0
    end

    fill(colors[color_index].blend_over(colors[color_index-1], elapsed))

    super
  end
end