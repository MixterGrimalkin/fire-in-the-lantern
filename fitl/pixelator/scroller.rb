require_relative '../color/colors'

class Scroller
  include Colors

  def initialize(size:, active: false, period: 1, oversample: 1, settings: OpenStruct.new)
    @settings = settings
    @size = size
    @active = active
    @period = period
    @oversample = oversample
    refresh_effectives

    @active = false
    @offset = 0
  end

  attr_reader :active, :offset, :size, :period, :oversample,
              :effective_size, :effective_period

  def period=(value)
    @period = value.to_f
    refresh_effectives
  end

  def oversample=(value)
    @offset = ((offset.to_f / oversample) * value).floor
    @oversample = [1, [value.to_i, max_oversample].min].max
    refresh_effectives
  end

  def refresh_effectives
    @effective_period = period.to_f / oversample
    @effective_size = size * oversample
  end

  def start
    @active = true
    @last_updated = Time.now
  end

  def stop
    @active = false
  end

  def check_and_update
    update(Time.now - last_updated) if active
  end

  def update(elapsed_seconds)
    return unless active

    if elapsed_seconds >= effective_period.abs
      @offset += (elapsed_seconds / effective_period).floor
      @offset %= (offset > 0 ? effective_size : -effective_size)
      @last_updated = Time.now
    end
  end

  def apply(pattern)
    oversampled = [nil] * (pattern.size * oversample)
    pixel = 0
    pattern.each do |color_a|
      oversample.times do
        p = (pixel + offset) % oversampled.size
        oversampled[p] = color_a
        pixel += 1
      end
    end

    return oversampled if oversample == 1

    result = [nil] * pattern.size
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
        oversample: oversample,
        active: active
    }
  end

  def to_s
    "#{period}x#{oversample}:#{active ? 'ON' : 'OFF'}"
  end
  alias :inspect :to_s

  private

  attr_reader :last_updated, :settings

  def max_oversample
    settings.max_oversample || 30
  end
end
