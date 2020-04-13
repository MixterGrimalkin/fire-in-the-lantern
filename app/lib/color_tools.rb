require_relative 'color'
require_relative 'color_a'
require_relative 'utils'

module ColorTools
  include Utils

  MAX = 255

  COLOR_COMPONENTS = [:red, :green, :blue, :white]
  COMPONENTS = COLOR_COMPONENTS + [:alpha]

  def validate_comps(r, g, b, w)
    [r, g, b, w].each do |c|
      raise ColorValueOutOfRange, "#{r},#{g},#{b},#{w}" unless (0..MAX).include?(c)
    end
  end

  def cap_comps(r, g, b, w)
    [r, g, b, w].collect { |c| [0, [MAX, c.to_i].min].max }
  end

  def scale_comps(scale, r, g, b, w)
    [r, g, b, w].collect { |c| (c * scale).floor }
  end

  def mix_color_as(color_as)
    color_sum = Color.new
    alpha_sum = 0.0
    color_count = 0
    alpha_count = 0

    color_as.each do |color_a|
      if color_a.color
        color_sum += color_a.color
        alpha_sum += color_a.alpha
        color_count += 1
      end
      alpha_count += 1
    end
    ColorA.new(
        color_count.zero? ? nil : color_sum / color_count,
        alpha_count.zero? ? 0.0 : alpha_sum / alpha_count
    )
  end

  def blend(under, over, alpha = 1.0)
    if under.nil? || alpha == 1.0
      over
    elsif over.nil? || alpha == 0.0
      under
    else
      under + ((over - under) * alpha)
    end
  end

  def blend_range(under, over, alpha)
    raise BlendRangeMismatch unless under.size==over.size

    if alpha == 1.0
      over
    elsif alpha == 0.0
      under
    else
      result = []
      over.each_with_index do |color, i|
        result << blend(under[i], color, alpha)
      end
      result
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
          config[:value][c], config[:target][c] = (c==:alpha ? [1, 1] : [0, 0])
      end
      config[:delta][c] = (config[:target][c].to_f - config[:value][c]) / (size - 1)
    end

    result = [ColorA.new] * surface_size

    size.times do |i|
      p = i + config[:start]
      result[p] = ColorA.new(
          Color.new(*COLOR_COMPONENTS.collect { |c| config[:value][c] }),
          config[:value][:alpha]
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
