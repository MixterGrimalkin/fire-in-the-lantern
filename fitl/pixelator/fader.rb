require_relative 'modifiers_config'

class Fader
  include ModifiersConfig

  def initialize(size)
    @size = size
    @alphas = [nil] * size
    @bouncers = [false] * size
    @initial_alphas = [nil] * size
    @target_alphas = [nil] * size
    @target_times = [nil] * size
    @elapsed_times = [nil] * size
    @last_updated = Time.now
    @active = false
  end

  attr_accessor :active

  attr_reader :size, :alphas, :bouncers, :initial_alphas, :target_alphas,
              :target_times, :elapsed_times, :last_updated

  def active?
    target_alphas.any?
  end

  def fade(time, start:, target:, bounce:)
    size.times do |i|
      fade_pixel i, time, start: start, target: target, bounce: bounce
    end
  end

  def fade_pixel(pixel, time, start:, target:, bounce:)
    if time == 0
      alphas[pixel] = target.to_f
      elapsed_times[pixel] = nil
    else
      alphas[pixel] = start.to_f
      bouncers[pixel] = bounce
      initial_alphas[pixel] = start.to_f
      target_alphas[pixel] = target.to_f
      target_times[pixel] = time.to_f
      elapsed_times[pixel] = 0.0
    end
  end

  def update(elapsed_seconds)
    size.times do |pixel|
      if elapsed_times[pixel]
        elapsed_times[pixel] += elapsed_seconds
        alphas[pixel] = initial_alphas[pixel] + (
        [1.0, (elapsed_times[pixel] / target_times[pixel])].min *
            (target_alphas[pixel] - initial_alphas[pixel])
        )
        if finished_fading? pixel
          if bouncers[pixel]
            initial_alphas[pixel], target_alphas[pixel] = target_alphas[pixel], initial_alphas[pixel]
            elapsed_times[pixel] = 0.0
          else
            elapsed_times[pixel] = nil
          end
        end
      end
    end
  end

  def finished_fading?(pixel)
    if target_alphas[pixel] > initial_alphas[pixel]
      alphas[pixel] >= target_alphas[pixel]
    else
      alphas[pixel] <= target_alphas[pixel]
    end
  end

  def check_and_update
    update Time.now - last_updated
    @last_updated = Time.now
  end

  def apply(pattern)
    result = []
    pattern.each_with_index do |color_a, i|
      result[i] = if alphas[i]
                    ColorA.new(color_a.color, alphas[i] * color_a.alpha)
                  else
                    pattern[i]
                  end
    end
    result
  end

  def to_s
    active ? '▶' : '⏸'
  end

  def inspect
    "<Fader active=#{active}>"
  end

end