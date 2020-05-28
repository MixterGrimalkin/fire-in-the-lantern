require_relative '../color/colors'
require_relative '../lib/utils'
require_relative 'story'
require_relative 'scene'
require_relative 'cue'
require_relative 'layer'

require 'json'

class Pixelator
  include Colors
  include Utils

  def initialize(neo_pixel:, mode: :layer, frame_rate: 30, osc_control_port: nil, settings: OpenStruct.new)
    @neo_pixel = neo_pixel
    @mode = mode
    @frame_rate = frame_rate
    @settings = settings

    OscControlHooks.new(self, port: osc_control_port, settings: settings).start if osc_control_port

    @base = [BLACK] * pixel_count
    @started = false
    clear
  end

  attr_reader :neo_pixel, :frame_rate, :started, :base, :settings

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_accessor :object
  private :object=
  alias_method :get, :object

  def clear
    self.object = self.send("new_#{mode}".to_sym)
    render
  end

  def build(config)
    self.object = self.send("build_#{mode}".to_sym, config)
  end

  def load_file(name)
    self.object = self.send("load_#{mode}".to_sym, name)
  end

  def save_file(name)
    File.write filename(name), JSON.pretty_generate(object.to_h)
  end

  MODES = [Layer, Cue, Scene, Story]

  attr_accessor :mode
  private :mode=

  MODES.each do |mode_class|
    mode = mode_class.name.downcase

    define_method (new_method = "new_#{mode}") do
      mode_class.new size: pixel_count, settings: settings
    end
    private new_method.to_sym

    define_method (build_method = "build_#{mode}") do |config|
      mode_class.new({settings: settings}.merge(config))
    end
    private build_method.to_sym

    define_method (load_method = "load_#{mode}") do |name|
      self.send(build_method.to_sym, read_json(filename(name)))
    end
    private load_method.to_sym

    define_method "#{mode}_mode" do
      self.mode = mode.to_sym
      clear
    end
  end

  def buffer
    object.render_over(base)
  end

  def render
    neo_pixel.write(buffer).render
  end

  def render_period
    1.0 / frame_rate
  end

  def start(period = render_period)
    raise AlreadyStarted if started

    @started = true

    @render_thread = Thread.new do
      while started
        ticker = Time.now

        object.update
        render

        if (elapsed = Time.now - ticker) < period
          sleep period - elapsed
        end
      end
    end

    self
  end

  def stop
    raise NotStarted unless started

    @started = false
    @render_thread.join

    self
  end

  def inspect
    "#<Pixelator[#{neo_pixel.class}] pixels:#{pixel_count} layers:#{layers.size} #{started ? 'STARTED' : 'STOPPED'}>"
  end

  def filename(name)
    "#{asset_locations[mode]}/#{name}.json"
  end

  private

  def asset_locations
    settings.asset_locations || {
        story: 'stories',
        scene: 'scenes',
        cue: 'cues',
        layer: 'layers',
    }
  end
end

AlreadyStarted = Class.new(StandardError)
NotStarted = Class.new(StandardError)
