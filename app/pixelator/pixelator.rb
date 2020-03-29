require_relative '../lib/color'
require_relative '../lib/color_tools'
require_relative '../lib/utils'
require_relative 'scene_manager'
require_relative 'layer'
require 'forwardable'
require 'json'
require 'yaml'

class Pixelator
  include ColorTools
  include SceneManager
  include Utils
  extend Forwardable

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @started = false
    @render_thread = nil
    clear
  end

  def clear
    @scene = Scene.new(pixel_count)
    render
  end

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_reader :neo_pixel, :started, :scene

  def_delegators :scene, :layers, :layer, :base, :[], :[]=

  def render
    neo_pixel.write(scene.build_buffer).render
  end

  def start(period = 0.01)
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

  def save_scene(filename)
    write(scene, filename)
    "Saved to: #{filename}"
  end

  def load_scene(filename)
    @scene = read(pixel_count, filename)
    render
    "Loaded from: #{filename}"
  end

  def self.from_config(file)
    yaml = YAML.load_file file
    px_config = yaml['Pixelator']
    unless (count = px_config['PixelCount']) && (adapter = px_config['Adapter'])
      puts "No configuration found in: #{file}"
      return
    end
    new(const_get(adapter).new count)
  rescue Errno::ENOENT
    puts "File not found: #{file}"
  end

  def inspect
    "#<Pixelator[#{neo_pixel.class}] pixels:#{pixel_count} layers:#{layers.size} #{started ? 'STARTED' : 'STOPPED'}>"
  end
end

NotAllowed = Class.new(StandardError)
