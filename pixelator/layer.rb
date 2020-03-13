require_relative '../support/color'
require_relative '../support/color_constants'

class Layer
  include ColorConstants

  def initialize(pixels, default = nil)
    @pixels = pixels
    @contents = [default] * pixels.size
    @global_opacity = 1.0
    @pixel_opacity = [1.0] * pixels.size
    @scroll_offset = 0
    @scroll_period = nil
    @scroll_last_updated = nil
  end

  attr_accessor :global_opacity, :pixel_opacity, :contents

  attr_reader :pixels, :scroll_offset, :scroll_period

  def []=(pixel, color)
    set(pixel, color)
  end

  def set(pixel, color, opacity = 1.0)
    raise PixelOutOfRangeError unless (0..(pixels.size-1)).include?(pixel)
    contents[pixel] = color
    pixel_opacity[pixel] = opacity
  end

  def fill(color, brightness = 1.0)
    pixels.size.times do |i|
      contents[i] = color&.with_brightness(brightness)
    end
  end

  def gradient(config)
    config = {
        start: 0,
        width: pixels.size,
        sym: false,
        value: {},
        target: {},
        delta: {}
    }.merge config

    size = config[:sym] ? (config[:width] / 2 + config[:width] % 2) : config[:width]

    COMPONENTS.each do |c|
      case config[c]
        when Integer
          config[:value][c], config[:target][c] = config[c], config[c]
        when Array
          config[:value][c], config[:target][c] = config[c][0], config[c][1]
        else
          config[:value][c], config[:target][c] = (c==:opacity ? [1, 1] : [0, 0])
      end
      config[:delta][c] = (config[:target][c].to_f - config[:value][c]) / (size - 1)
    end

    size.times do |i|
      p = i + config[:start]
      pixel_opacity[p] = config[:value][:opacity]
      contents[p] =
          Color.safe(
              config[:value][:red].to_i,
              config[:value][:green].to_i,
              config[:value][:blue].to_i,
              config[:value][:white].to_i
          )
      if config[:sym]
        mirror_p = config[:start] + config[:width] - i - 1
        pixel_opacity[mirror_p] = pixel_opacity[p]
        contents[mirror_p] = contents[p]
      end
      COMPONENTS.each { |c| config[:value][c] += config[:delta][c] }
    end

    self
  end

  def scroll_by(amount)
    @scroll_offset += amount
  end

  def start_scroll(period)
    @scroll_period = period
    @scroll_last_updated = Time.now
  end

  def stop_scroll
    @scroll_last_updated = nil
  end

  def update_scroll(elapsed_seconds)
    return unless @scroll_last_updated

    if elapsed_seconds >= @scroll_period
      @scroll_offset += (elapsed_seconds / @scroll_period)
      @scroll_last_updated = Time.now
    end
  end

  def update
    update_scroll Time.now - @scroll_last_updated if @scroll_last_updated
  end

  def render_over(base_layer)
    contents.each_with_index do |color, i|
      unless color.nil?
        p = (pixels[i] + @scroll_offset) % base_layer.size
        # base_layer[p] = color.blend_over(base_layer[p], global_opacity)
        base_layer[p] = color.blend_over(base_layer[p], opacity_for_pixel(i))
      end
    end
    base_layer
  end

  def combine_keys(other)
    (key.to_s + other.key.to_s).to_sym
  end

  def ==(other)
    pixels == other.pixels
  end

  def +(other)
    Layer.new(pixels + other.pixels)
  end

  def -(other)
    Layer.new(pixels - other.pixels)
  end

  def layer_def
    result = {
        pixels: pixels,
        contents: contents.collect {|c| c.nil? ? BLACK : c },
        opacity: global_opacity,
        pixel_opacity: pixel_opacity
    }
    if @scroll_last_updated
      result[:scroll] = @scroll_period
    end
    result
  end

  def inspect
    "#<Layer{#{pixels.size}} α=#{global_opacity} [#{stringify_scroll_period}]>"
  end

  private

  def stringify_scroll_period
    if scroll_period.nil?
      '-0.0-'
    elsif scroll_period > 0
      "-#{scroll_period}>"
    else
      "<#{-scroll_period}-"
    end
  end

  def opacity_for_pixel(p)
    pixel_opacity[p] * global_opacity
  end

end

class PixelOutOfRangeError < StandardError;
end