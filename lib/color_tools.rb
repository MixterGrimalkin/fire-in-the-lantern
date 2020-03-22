require_relative 'color'
require_relative 'color_a'
require_relative 'utils'

module ColorTools
  include Utils

  COLOR_COMPONENTS = [:red, :green, :blue, :white]
  COMPONENTS = COLOR_COMPONENTS + [:opacity]

  def validate_comps(r, g, b, w)
    [r, g, b, w].each do |c|
      unless c.nil? || (0..255).include?(c)
        raise ColorValueOutOfRange, "#{r},#{g},#{b},#{w}"
      end
    end
  end

  def scale_comps(scale, r, g, b, w)
    [r, g, b, w].collect do |c|
      c.nil? ? nil : (c * scale).floor
    end
  end

  def mix_colors(color_as)
    buffer = {
        red: [], green: [], blue: [], white: [], alpha: []
    }
    color_as.each do |color_a|
      if (c = color_a.color)
        buffer[:red] << c.red
        buffer[:green] << c.green
        buffer[:blue] << c.blue
        buffer[:white] << c.white if c.white
        buffer[:alpha] << color_a.alpha
      else
        buffer[:alpha] << 0.0
      end
    end
    ColorA.new(
        Color.safe(
            avg_array(buffer[:red]),
            avg_array(buffer[:green]),
            avg_array(buffer[:blue]),
            avg_array(buffer[:white]),
        ),
        avg_array(buffer[:alpha])
    )
  end

  def blend(under, over, alpha = 1.0)
    if under.nil? || alpha == 1.0
      over
    elsif over.nil? || alpha == 0.0
      under
    else
      over_w = over.white || 0
      under_w = under.white || 0
      Color.new(
          (under.red + (alpha * (over.red - under.red))).floor,
          (under.green + (alpha * (over.green - under.green))).floor,
          (under.blue + (alpha * (over.blue - under.blue))).floor,
          (under_w + (alpha * (over_w - under_w))).floor
      )
    end
  end

  def draw_gradient(surface_size, config)
    config = {
        start: 0, width: surface_size, sym: false,
        value: {}, target: {}, delta: {}
    }.merge config

    size = config[:sym] ? (config[:width] / 2 + config[:width] % 2) : config[:width]

    COMPONENTS.each do |c|
      case config[c]
        when Integer
          config[:value][c], config[:target][c] = config[c], config[c]
        when Array
          config[:value][c], config[:target][c] = config[c][0], config[c][1]
        else
          config[:value][c], config[:target][c] = (c==:opacity ? [1, 1] : [0, 0])
      end
      config[:delta][c] = (config[:target][c].to_f - config[:value][c]) / (size - 1)
    end

    result = [ColorA.new] * surface_size

    size.times do |i|
      p = i + config[:start]
      result[p] = ColorA.new(
          Color.safe(*COLOR_COMPONENTS.collect { |c| config[:value][c] }),
          config[:value][:opacity]
      )
      if config[:sym]
        mirror_p = config[:start] + config[:width] - i - 1
        result[mirror_p] = result[p]
      end
      COMPONENTS.each { |c| config[:value][c] += config[:delta][c] }
    end

    result
  end

end

ColorValueOutOfRange = Class.new(StandardError)
BlendRangeMismatch = Class.new(StandardError)
