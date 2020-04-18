require_relative '../lib/color'
require_relative '../lib/color_tools'
require_relative '../lib/utils'
require_relative 'scene'
require 'forwardable'
require 'json'

class Pixelator
  include ColorTools
  include Utils
  extend Forwardable

  def initialize(neo_pixel:, fps: 30, monitor_fps: false, scenes_dir: 'scenes', default_crossfade: 0)
    @neo_pixel = neo_pixel
    @fps = fps
    @monitor_fps = monitor_fps
    @scenes_dir = scenes_dir
    @default_crossfade = default_crossfade
    @render_thread = nil
    @started = false
    clear
  end

  def clear
    @scene = Scene.new(pixel_count)
    @incoming_scene = nil
    @crossfade_time = nil
    @crossfade_started_at = nil
    render
  end

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_reader :neo_pixel, :fps, :started, :scene, :incoming_scene,
              :crossfade_time, :default_crossfade, :scenes_dir

  attr_accessor :monitor_fps

  def_delegators :scene, :layers, :layer, :base, :[], :[]=

  def render
    neo_pixel.write(build_crossfade_buffer).render
  end

  def render_period
    1.0 / fps
  end

  def start(period = render_period)
    raise NotAllowed if started

    @started = true

    monitor_buffer = []

    @render_thread = Thread.new do
      while started
        ticker = Time.now
        scene.update
        incoming_scene.update if incoming_scene
        render
        if (elapsed = Time.now - ticker) < period
          sleep period - elapsed
        end
        if monitor_fps
          monitor_buffer << (1.0 / (Time.now-ticker))
          if monitor_buffer.size >= 50
            puts "Pixelator fps=#{monitor_buffer.sum(0.0) / monitor_buffer.size}"
            monitor_buffer = []
          end
        end
      end
    end

    self
  end

  def stop
    raise NotAllowed unless started

    @started = false
    @render_thread.join

    self
  end

  def all_on
    stop if started
    neo_pixel.on
    self
  end

  def all_off
    stop if started
    neo_pixel.off
    self
  end

  def save_scene(scene_name)
    File.write(
        "#{scenes_dir}/#{scene_name}.json",
        scene.to_conf.to_json
    )
    "Saved #{scene_name}"
  end

  def load_scene(scene_name, crossfade: default_crossfade)
    set_scene create_scene_from_file(scene_name), crossfade: crossfade
    render
    "Loaded #{scene_name}"
  end

  def set_scene(new_scene, crossfade: default_crossfade)
    if crossfade == 0
      @scene = new_scene
      @crossfade_time = nil
    else
      @incoming_scene = new_scene
      @crossfade_time = crossfade
      @crossfade_started_at = Time.now
    end
  end

  def inspect
    "#<Pixelator[#{neo_pixel.class}] pixels:#{pixel_count} layers:#{layers.size} #{started ? 'STARTED' : 'STOPPED'}>"
  end

  private

  def create_scene_from_file(scene_name)
    result = Scene.new pixel_count
    result.from_conf(
        symbolize_keys(JSON.parse(
            File.read("#{scenes_dir}/#{scene_name}.json")
        ))
    )
    result
  end

  def fade_time_elapsed
    Time.now - @crossfade_started_at
  end

  def build_crossfade_buffer
    buffer = scene.build_buffer
    if crossfade_time && incoming_scene
      incoming_buffer = incoming_scene.build_buffer
      elapsed = fade_time_elapsed.to_f
      if elapsed >= crossfade_time
        @scene = incoming_scene
        @incoming_scene = nil
        @crossfade_time = nil
        buffer = incoming_buffer
      else
        alpha = elapsed / crossfade_time
        buffer = blend_range buffer, incoming_buffer, alpha
      end
    end
    buffer
  end
end

NotAllowed = Class.new(StandardError)