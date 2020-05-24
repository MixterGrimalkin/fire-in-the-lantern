require_relative 'color'
require_relative 'color_a'
require_relative 'utils'

class ColorTools

  COMPONENTS = [:red, :green, :blue, :white, :alpha]

  class << self

    def gradient(from, to, size:, sym: false)
      result = [ColorA.new] * size

      from = ColorA.cast(from)
      to = ColorA.cast(to)
      arc_size = sym ? (size / 2.0).ceil : size

      current = {}
      target = {}
      delta = {}

      COMPONENTS.each do |c|
        current[c] = from.send(c) || 0
        target[c] = to.send(c) || 0
        delta[c] = (target[c].to_f - current[c]) / (arc_size - 1)
      end

      arc_size.times do |i|
        result[i] = ColorA.create(*COMPONENTS.collect { |c| current[c] })
        if sym
          mirror_p = size - i - 1
          result[mirror_p] = result[i]
        end
        COMPONENTS.each { |c| current[c] += delta[c] }
      end

      result
    end

  end

end
