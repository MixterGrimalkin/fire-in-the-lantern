require_relative 'color'

module Colors
  class ColorA
    def initialize(color = nil, alpha = 1.0)
      @color = color
      @alpha = alpha
    end

    attr_reader :color, :alpha

    def red
      color&.red
    end

    def green
      color&.green
    end

    def blue
      color&.blue
    end

    def white
      color&.white
    end

    def ==(other)
      other.is_a?(ColorA) && color == other.color && alpha == other.alpha
    end

    def blend_over(under, opacity = 1.0)
      return under if color.nil?
      color.blend_over under&.color, (alpha * opacity)
    end

    class << self

      def create(red = 0, green = red, blue = red, white = 0, alpha = 1.0)
        ColorA.new(Color.new(red, green, blue, white), alpha)
      end

      def cast(object, alpha = 1.0)
        case object
          when ColorA
            if alpha == 1.0
              object
            else
              ColorA.new(object.color, object.alpha * alpha)
            end
          when Color
            ColorA.new(object, alpha)
          else
            ColorA.new(nil, alpha)
        end
      end

      def mix(colors)
        color_sum = Color.new
        alpha_sum = 0.0
        color_count = 0
        alpha_count = 0
        colors.each do |color|
          color_a = ColorA.cast(color)
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

      def from_s(color_a_string)
        return nil unless color_a_string && !color_a_string.empty?
        comps = color_a_string[1..-2].split('x')
        ColorA.new Color.from_s(comps[0]), comps[1].to_f
      end

    end

    def to_s
      "[#{color.to_s}x#{alpha}]"
    end

    alias :inspect :to_s
  end
end
