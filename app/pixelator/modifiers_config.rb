module ModifiersConfig

  def pixel_config(pixel)
    {
        bouncer: bouncers[pixel],
        initial_alpha: initial_alphas[pixel],
        current_alpha: alphas[pixel],
        target_alpha: target_alphas[pixel],
        target_time: target_times[pixel]
    }
  end

  def to_conf
    {
        bouncers: bouncers,
        initial_alphas: initial_alphas,
        target_alphas: target_alphas,
        target_times: target_times
    }
  end

  def from_conf(conf)
    size.times do |pixel|
      bouncers[pixel] = conf[:bouncers][pixel]
      initial_alphas[pixel] = conf[:initial_alphas][pixel]
      alphas[pixel] = conf[:initial_alphas][pixel]
      target_alphas[pixel] = conf[:target_alphas][pixel]
      target_times[pixel] = conf[:target_times][pixel]
      elapsed_times[pixel] = 0.0 if target_times[pixel]
    end
    @bouncers = conf[:bouncers]
    self
  end

end