require_relative 'pixel'
require_relative 'pixel_group'

class Pixelator

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @pixels = []
    pixel_count.times { |i| @pixels << Pixel.new(i) }
    @groups = {all: PixelGroup.new(@pixels)}
    @started = false
  end

  attr_reader :neo_pixel, :pixels, :started

  def pixel_count
    @neo_pixel.pixel_count
  end

  def start(period = 0.01)
    raise NotAllowed if @started

    @started = true
    Thread.new do
      while @started
        render
        sleep period
      end
    end
  end

  def stop
    raise NotAllowed unless @started

    @started = false
  end

  def render
    pixels.each { |p| neo_pixel.set(p.number, p.get) }
    neo_pixel.render
  end

  def group(group_def)
    return unless group_def.is_a?(Hash) && group_def.size == 1

    key, criteria = group_def.first[0], group_def.first[1]

    group =
        PixelGroup.new(pixels.select do |p|
          case criteria
            when Range, Array
              criteria.include?(p.number)
            when Proc
              criteria.call p
          end
        end)

    self.class.send(:define_method, key.to_sym, proc { group })

    @groups[key] = group
  end

  def []=(key, group)
    return unless key.is_a?(Symbol) and group.is_a?(PixelGroup)

    @groups[key] = group
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

NotAllowed = Class.new(StandardError)
