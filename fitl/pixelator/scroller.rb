require_relative '../color/colors'

class Scroller
  include Colors

  def initialize(size, period: 1.0, oversample: nil, settings: OpenStruct.new)
    @settings = settings
    @size = size
    @period = period
    @oversample = oversample || max_oversample
    refresh_effectives

    @active = false
    @offset = 0
  end

  attr_reader :size, :active, :offset, :period,
              :effective_period, :effective_size,
              :last_updated, :oversample

  def period=(value)
    @period = value.to_f
    refresh_effectives
  end

  def oversample=(value)
    @offset /= oversample
    @oversample = [1, [value.to_i, max_oversample].min].max
    refresh_effectives
    ref
  end

  def refresh_effectives
    @effective_period = period.to_f / oversample
    @effective_size = size * oversample
  end

  def check_and_update
    update(Time.now - last_updated) if active
  end

  def start
    @active = true
    @last_updated = Time.now
    self
  end

  def stop
    @active = false
    self
  end

  def update(elapsed_seconds)
    return unless active

    if elapsed_seconds >= effective_period.abs
      @offset += (elapsed_seconds / effective_period)
      @offset %= (offset > 0 ? effective_size : -effective_size)
      @last_updated = Time.now
    end
  end

  def apply(pattern)
    oversampled = [ColorA.new] * (pattern.size * oversample)
    pixel = 0
    pattern.each do |color_a|
      oversample.times do
        p = (pixel + offset) % oversampled.size
        oversampled[p] = color_a
        pixel += 1
      end
    end

    return oversampled if oversample == 1

    result = [ColorA.new] * pattern.size
    average_buffer = []
    pixel = 0
    oversampled.each do |color_a|
      average_buffer << color_a
      if average_buffer.size == oversample
        result[pixel] = ColorA.mix(average_buffer)
        average_buffer = []
        pixel += 1
      end
    end
    result
  end

  def to_h
    {
        size: size,
        period: period,
        oversample: oversample
    }
  end

  class << self

    def from_h(hash)

    end


  end


  def to_s
    "#{period}x#{over_sample}"
  end
  alias :inspect :to_s

  DEFAULT_OVERSAMPLE = 25

  private

  def max_oversample
    settings.max_oversample || DEFAULT_OVERSAMPLE
  end

  attr_reader :settings
end
