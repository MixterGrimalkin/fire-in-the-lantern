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
      unless c.nil? || (0..MAX).include?(c)
        raise ColorValueOutOfRange, "#{r},#{g},#{b},#{w}"
      end
    end
  end

  def cap_comps(r, g, b, w)
    [r, g, b, w].collect do |c|
      c.nil? ? nil : [0, [MAX, c.to_i].min].max
    end
  end

  def scale_comps(scale, r, g, b, w)
    [r, g, b, w].collect do |c|
      c.nil? ? nil : (c * scale).floor
    end
  end

  def mix_colors(colors)
    buffer = {
        color: [], alpha: []
    }
    colors.collect(&:a!).each do |color_a|
      if color_a.color
        buffer[:color] << color_a.color.unbound
        buffer[:alpha] << color_a.alpha
      else
        buffer[:alpha] << 0.0
      end
    end
    ColorA.new(
        avg_array(buffer[:color], zero: Color.new).bound,
        avg_array(buffer[:alpha])
    )
  end

  def blend(under, over, alpha = 1.0)
    if under.nil? || alpha == 1.0
      over
    elsif over.nil? || alpha == 0.0
      under
    else
      under, over = [under, over].collect {|c| c.c!.unbound }
      (under + ((over - under) * alpha)).bound
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
        result << color.blend_over(under[i], alpha)
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
