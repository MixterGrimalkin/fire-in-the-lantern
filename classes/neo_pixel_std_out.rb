require_relative 'neo_pixel'

class NeoPixelStdOut < NeoPixel

  def initialize(pixel_count)
    super(pixel_count, mode: :rgb)
  end

  def show(buffer)
    output = ''
    buffer.each_slice(3) do |rgb|
      average = (((rgb[0] + rgb[1] + rgb[2]) / 3) / 255.0) * 100
      output <<
          if average < 25
            '.'
          elsif average < 50
            '-'
          elsif average < 75
            '='
          else
            '#'
          end
    end
    puts output
  end

end