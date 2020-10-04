require './lib/colours'

module Fitl
  class Pen
    class << self

      def block(colour, size)
        [colour] * size
      end

      def blocks(*colour_size)
        result = []
        colour_size.each_slice(2) do |colour, size|
          result << block(colour, size)
        end
        result.flatten
      end

      def gradient(from, to, size:, sym: false)
        result = [nil] * size

        arc_size = sym ? (size / 2.0).ceil : size

        current = {}
        target = {}
        delta = {}

        RGBW_A.each do |c|
          current[c] = from.send(c) || 0
          target[c] = to.send(c) || 0
          delta[c] = (target[c].to_f - current[c]) / (arc_size - 1)
        end

        arc_size.times do |i|
          result[i] = Colour.new(*RGBW.collect { |c| current[c] }, alpha: current[:alpha])
          if sym
            mirror_i = size - i - 1
            result[mirror_i] = result[i]
          end
          RGBW_A.each { |c| current[c] += delta[c] }
        end

        result
      end

      def repeat(pattern, times)
        pattern * times
      end

    end
  end
end
