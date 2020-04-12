class Modifiers

  def initialize(size)
    @alphas = [nil] * size
    @initial_alphas = [nil] * size
    @target_alphas = [nil] * size
    @target_times = [nil] * size
    @elapsed_times = [nil] * size
    @last_updated = Time.now
  end

  attr_accessor :alphas, :initial_alphas, :target_alphas,
                :target_times, :elapsed_times, :last_updated

  def fade(time, initial_alpha, target_alpha)
    alphas.size.times do |i|
      fade_pixel i, time, initial_alpha, target_alpha
    end
  end

  def fade_pixel(pixel, time, initial_alpha, target_alpha)
    if time == 0
      alphas[pixel] = target_alpha.to_f
      elapsed_times[pixel] = nil
    else
      alphas[pixel] = initial_alpha.to_f
      initial_alphas[pixel] = initial_alpha.to_f
      target_alphas[pixel] = target_alpha.to_f
      target_times[pixel] = time.to_f
      elapsed_times[pixel] = 0.0
    end
  end

  def update(elapsed_seconds)
    alphas.size.times do |i|
      if elapsed_times[i]
        elapsed_times[i] += elapsed_seconds
        alphas[i] = initial_alphas[i] + (
            [1.0, (elapsed_times[i] / target_times[i])].min *
                (target_alphas[i] - initial_alphas[i])
        )
      end
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

end