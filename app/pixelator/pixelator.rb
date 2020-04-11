require_relative '../lib/color'
require_relative '../lib/color_tools'
require_relative '../lib/utils'
require_relative 'scene'
require_relative 'layer'
require 'forwardable'
require 'json'

class Pixelator
  include ColorTools
  include Utils
  extend Forwardable

  def initialize(neo_pixel:, render_period: 0.01, scenes_dir: 'scenes')
    @neo_pixel = neo_pixel
    @started = false
    @render_thread = nil
    @render_period = render_period
    @scenes_dir = scenes_dir
    clear
  end

  def clear
    @scene = Scene.new(pixel_count)
    render
  end

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_reader :neo_pixel, :render_period, :started, :scene, :scenes_dir

  def_delegators :scene, :layers, :layer, :base, :[], :[]=

  def render
    neo_pixel.write(scene.build_buffer).render
  end

  def start(period = render_period)
    raise NotAllowed if started

    @started = true

    @render_thread = Thread.new do
      while started
        scene.update
        render
        sleep period
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

  def load_scene(scene_name)
    @scene = Scene.new pixel_count
    scene.from_conf(
        symbolize_keys(JSON.parse(
            File.read("#{scenes_dir}/#{scene_name}.json")
        ))
    )
    render
    "Loaded #{scene_name}"
  end

  def inspect
    "#<Pixelator[#{neo_pixel.class}] pixels:#{pixel_count} layers:#{layers.size} #{started ? 'STARTED' : 'STOPPED'}>"
  end
end

NotAllowed = Class.new(StandardError)
