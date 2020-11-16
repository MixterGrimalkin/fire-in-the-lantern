module Fitl
  class Colour
    def initialize(red = 0, green = red, blue = red, white = 0, alpha: 1.0)
      @real_red, @real_green, @real_blue, @real_white, @alpha = red, green, blue, white, alpha
    end

    attr_reader :real_red, :real_green, :real_blue, :real_white, :alpha

    def red
      @red ||= clip real_red
    end

    def green
      @green ||= clip real_green
    end

    def blue
      @blue ||= clip real_blue
    end

    def white
      @white ||= clip real_white
    end

    def components
      @components ||= [red, green, blue, white]
    end

    def flat
      return self if alpha == 1.0

      Colour.new(
          red * alpha,
          green * alpha,
          blue * alpha,
          white * alpha,
          alpha: 1.0
      )
    end

    def ==(other)
      red == other.red &&
          green == other.green &&
          blue == other.blue &&
          white == other.white &&
          alpha == other.alpha
    end

    def +(other)
      return self unless other.alpha > 0
      return other unless alpha > 0

      if alpha > other.alpha
        dom, sub = self, other
      else
        dom, sub = other, self
      end

      Colour.new(
          dom.real_red + (sub.real_red * sub.alpha),
          dom.real_green + (sub.real_green * sub.alpha),
          dom.real_blue + (sub.real_blue * sub.alpha),
          dom.real_white + (sub.real_white * sub.alpha),
          alpha: dom.alpha
      )
    end

    def -(other)
      return self unless other.alpha > 0

      Colour.new(
          real_red - (other.real_red * other.alpha),
          real_green - (other.real_green * other.alpha),
          real_blue - (other.real_blue * other.alpha),
          real_white - (other.real_white * other.alpha),
          alpha: alpha
      )
    end

    def *(brightness)
      Colour.new *scale(brightness.to_f, real_red, real_green, real_blue, real_white), alpha: alpha
    end

    def /(dimness)
      Colour.new *scale(1 / dimness.to_f, real_red, real_green, real_blue, real_white), alpha: alpha
    end

    def -@
      Colour.new(
          MAX - red,
          MAX - green,
          MAX - blue,
          MAX - white,
          alpha: alpha
      )
    end

    def override(red: nil, green: nil, blue: nil, white: nil, alpha: nil)
      Colour.new(
          red || real_red,
          green || real_green,
          blue || real_blue,
          white || real_white,
          alpha: alpha || self.alpha
      )
    end

    def adjust(red: 0, green: 0, blue: 0, white: 0, alpha: 0.0)
      Colour.new(
          real_red + red,
          real_green + green,
          real_blue + blue,
          real_white + white,
          alpha: self.alpha + alpha
      )
    end

    def normalize
      multiplier = MAX / components.max.to_f
      return self if multiplier == 1.0

      Colour.new(
          *components.collect { |c| (c * multiplier).ceil },
          alpha: alpha
      )
    end

    def blend_over(underlay, amount = 1.0)
      Colour.blend(underlay, self, amount)
    end

    def blend_under(overlay, amount = 1.0)
      Colour.blend(self, overlay, amount)
    end

    class << self

      def blend(under, over, amount = 1.0)
        if under.nil? || (over.alpha == 1.0 && amount == 1.0)
          over
        elsif over.nil? || over.alpha == 0.0 || amount == 0.0
          under
        else
          under + ((over - under) * amount)
        end
      end

      def blend_range(under, over, amount = 1.0)
        raise BlendRangeMismatch unless under.size == over.size

        over.size.times.collect do |i|
          blend(under[i], over[i], amount)
        end
      end

      def mix(colours)
        return nil if colours.nil? || colours.empty?

        colour_sum = Colour.new
        alpha_sum = 0.0
        colour_count = 0

        colours.each do |colour|
          if colour
            colour_sum += colour
            alpha_sum += colour.alpha
            colour_count += 1
          end
        end

        return nil if colour_count.zero?

        result_colour = colour_sum / colour_count
        result_alpha = alpha_sum / colours.size

        Colour.new(*result_colour.components, alpha: result_alpha)
      end

      def from_s(string)
        return nil unless string && !string.empty?
        components, alpha = string.split('x')
        Colour.new *components[1..-2].split(',').collect(&:to_i), alpha: (alpha || 1.0).to_f
      end

      def from_string_array(array)
        return nil unless array
        array.collect { |color_string| Colour.from_s color_string }
      end
    end

    def to_s
      "(#{red},#{green},#{blue},#{white})x#{alpha}"
    end

    alias :inspect :to_s

    private

    def clip(comp)
      [0, [MAX, comp.to_i].min].max
    end

    def scale(scale, r, g, b, w)
      [r, g, b, w].collect { |c| (c * scale).floor }
    end

    MAX = 255

    BlendRangeMismatch = Class.new(StandardError)
  end
end