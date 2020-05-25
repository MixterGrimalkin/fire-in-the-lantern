require_relative 'colors'

module Colors
  class Tools
    class << self

      def block(color, size)
        [ColorA.cast(color)] * size
      end

      def blocks(*args)
        result = []
        args.each_slice(2) do |slice|
          result << block(slice[0], slice[1])
        end
        result.flatten
      end

      def gradient(from, to, size:, sym: false)
        result = [ColorA.new] * size

        from = ColorA.cast(from)
        to = ColorA.cast(to)
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
          result[i] = ColorA.create(*RGBW_A.collect { |c| current[c] })
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
