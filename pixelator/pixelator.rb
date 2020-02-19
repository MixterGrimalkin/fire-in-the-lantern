require_relative 'pixel'

class Pixelator

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @pixels = []
    pixel_count.times { |i| @pixels << Pixel.new(i) }
    @groups = {}
  end

  attr_reader :neo_pixel, :pixels

  def pixel_count
    @neo_pixel.pixel_count
  end

  def render
    pixels.each { |p| neo_pixel.set(p.number, p.get) }
    neo_pixel.render
  end

  def []=(key, criteria)
    return unless key.is_a? Symbol

    @groups[key] = pixels.select do |p|
      case criteria
        when Range, Array
          criteria.include?(p.number)
        when Proc
          criteria.call p
      end
    end
  end

  def [](key)
    case key
      when Integer
        @pixels[key]
      when Symbol
        @groups[key]
    end
  end

end