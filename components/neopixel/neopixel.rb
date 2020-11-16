require './lib/colours'

module Fitl
  class Neopixel
    include Colours

    def initialize(pixel_count:, mode: :rgb)
      @pixel_count = pixel_count
      @mode = mode.to_sym
      @contents = [BLACK] * pixel_count
    end

    attr_reader :pixel_count, :mode, :contents

    attr_accessor :fps_meter

    def [](pixel)
      raise BadPixelNumber unless (0..pixel_count).include? pixel
      contents[pixel]
    end

    def []=(pixel, colour)
      raise BadPixelNumber unless (0..pixel_count).include? pixel
      contents[pixel] = colour.flat
    end

    def on(colour = FULL_WHITE)
      write [colour] * pixel_count
      render
    end

    def off
      write [BLACK] * pixel_count
      render
    end

    def write(contents)
      raise BadPixelNumber unless contents.size == pixel_count
      @contents = contents.collect(&:flat)
      self
    end

    def render
      buffer = contents.collect do |colour|
        case mode
          when :rgb
            [colour.red, colour.green, colour.blue]
          when :grb
            [colour.green, colour.red, colour.blue]
          when :rgbw
            [colour.red, colour.green, colour.blue, colour.white]
          else
            raise BadOutputMode, mode.to_s
        end
      end.flatten

      fps_meter.log_render if fps_meter

      while buffer.size % 3 != 0
        buffer << 0
      end

      show buffer

      self
    end

    def show(buffer)
      # --> Update display here <-- #
    end

    def close
      # --> Shutdown display here <-- #
    end

    def to_s
      "<#{self.class.name} #{mode.to_s.upcase}x#{pixel_count}>"
    end

    alias :inspect :to_s

    def rgb_count
      if mode == :rgbw
        ((pixel_count * 4) / 3.0).ceil
      else
        pixel_count
      end
    end

    def test(time = 1)
      print '>> NeoPixel test running.'
      on RED
      sleep time

      print '.'
      on GREEN
      sleep time

      print '.'
      on BLUE
      sleep time

      if mode == :rgbw
        print '.'
        on WARM_WHITE
        sleep time
      end

      print '.'
      on
      sleep time

      off
      puts 'OK'
    end

    BadPixelNumber = Class.new(StandardError)
    BadOutputMode = Class.new(StandardError)
  end
end
