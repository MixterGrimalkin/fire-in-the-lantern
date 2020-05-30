require_relative '../color/colors'

class Scroller
  include Colors

  def initialize(size:, period: 1, oversample: 1, active: false, assets: Assets.new)
    @size = size
    @period = period
    @oversample = oversample
    @active = active
    @assets = assets

    refresh_effectives

    @offset = 0
    @last_updated = Time.now
  end

  attr_reader :offset, :size, :period, :oversample, :active,
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
        period: period,
        oversample: oversample,
        active: active
    }
  end

  def to_s
    if active
        if period > 0
          '◁▶'
        elsif period < 0
          '◀▷'
        else
          '◁▷'
        end
    else
      '⏸'
    end
  end

  def inspect
    "<Scroller active=#{active} period=#{period}s oversample=#{oversample}>"
  end


  private

  attr_reader :last_updated, :assets

  def max_oversample
    assets.settings.max_oversample || 30
  end
end
