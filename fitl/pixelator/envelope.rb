class Envelope
  include Utils

  def initialize(object, method, off: 0.0, max: 1.0, loop: false,
                 attack_time: 1, attack_profile: {},
                 sustain_time: 1, sustain_profile: 1.0,
                 release_time: 1, release_profile: {})
    @object = object
    @method = method
    @off = off.to_f
    @max = max.to_f
    @loop = loop
    @attack_time = attack_time
    @attack_profile = attack_profile
    @sustain_time = sustain_time
    @sustain_profile = sustain_profile.to_f
    @release_time = release_time
    @release_profile = release_profile
    @started_at = nil
    @started = false
  end

  attr_reader :object, :method, :off, :max, :loop,
              :attack_time, :attack_profile,
              :sustain_time, :sustain_profile,
              :release_time, :release_profile,
              :started_at, :started

  def sustain_value
    @sustain_value ||= (sustain_profile * max)
  end

  def start
    return if started

    @started_at = Time.now

    Thread.new do
      @started = true
      while started
        update
        sleep 0.01
      end
    end

    until started
    end
  end

  def stop
    @started = false
  end

  TIME = 0
  VALUE = 1

  def value_at(time)
    time = time.negative? ? 0.0 : time.to_f
    time %= (attack_time + sustain_time + release_time) if loop

    if time <= attack_time
      value_from_curve(attack_curve, time)
    elsif time <= (attack_time + sustain_time)
      sustain_value
    elsif time <= (attack_time + sustain_time + release_time)
      value_from_curve(release_curve, time - attack_time - sustain_time)
    else
      release_curve.last[VALUE]
    end
  end

  private

  def update
    return unless started

    object.send(method, value_at(Time.now - started_at))
  end

  def value_from_curve(curve, time)
    curve.each_with_index do |node, i|
      next if i.zero?

      if time <= node[TIME]
        time_before, value_before = curve[i-1]
        time_after, value_after = node
        progress = (time - time_before) / (time_after - time_before)
        return interpolate(value_before, value_after, progress)
      end
    end
    nil
  end

  def attack_curve
    @attack_curve ||= generate_curve(base_attack_curve,
                                     attack_profile,
                                     attack_time,
                                     end_value: sustain_value)
  end

  def release_curve
    @release_curve ||= generate_curve(base_release_curve,
                                      release_profile,
                                      release_time,
                                      end_value: loop ? attack_curve.first[VALUE] : nil)
  end

  def generate_curve(base_curve, profile, total_time, end_value: nil)
    normalised_curve = base_curve.dup
    profile.each do |time, value|
      normalised_curve[time.to_f] = (value * max)
    end
    curve = normalised_curve.sort.collect do |time, value|
      [time * total_time, value]
    end
    curve.last[VALUE] = end_value if end_value
    curve
  end

  def base_attack_curve
    {0.0 => off, 1.0 => sustain_value}
  end

  def base_release_curve
    {0.0 => sustain_value, 1.0 => off}
  end
end