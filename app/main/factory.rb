class Factory
  include Utils

  def initialize(filename: '../.fitl.json', adapter_override: nil)
    @filename = filename
    @config = read_config
    @adapter_override = adapter_override
  end

  attr_reader :filename, :config, :adapter_override

  def settings
    @settings ||= OpenStruct.new(config.fetch(:Settings, {}))
  end

  def neo
    @neo ||= neo_class.new(neo_config)
  end

  def px
    @px ||= Pixelator.new(px_config)
  end

  def osc
    @osc ||= OscServer.new(osc_config)
  end

  def scn
    px.scene
  end

  def clear
    px.clear
  end

  def save_config
    write_config config
  end

  private

  def read_config
    if File.exists? filename
      write_config DEFAULT_CONFIG.merge(symbolize_keys JSON.parse File.read filename)
    else
      write_config DEFAULT_CONFIG
    end
  end

  def write_config(conf)
    File.write filename, JSON.pretty_generate(conf)
    conf
  end

  def neo_class
    Object.const_get(adapter_override || config.fetch(:Adapter))
  end

  def neo_key
    neo_class.name.to_sym
  end

  def neo_config
    config.fetch(:NeoPixel).merge(config.fetch(neo_key, {}))
  end

  def px_config
    config.fetch(:Pixelator).merge(neo_pixel: neo, settings: settings)
  end

  def osc_config
    config.fetch(:OscServer).merge(neo_pixel: neo)
  end

  DEFAULT_CONFIG = {
      Adapter: 'OscNeoPixel',
      Pixelator: {
          scenes_dir: 'scenes',
          default_crossfade: 1
      },
      OscServer: {
          port: 3333,
          address: 'neo_pixel'
      },
      NeoPixel: {
          pixel_count: 25,
          mode: :rgb,
      },
      HttpNeoPixel: {
          host: 'localhost',
          port: 4567,
          path: 'data'
      },
      OscNeoPixel: {
          host: 'localhost',
          port: 3333,
          address: 'data'
      },
      WsNeoPixel: {
          pin: 18,
          brightness: 255,
          options: {
              freq: 800_000,
              dma: 5,
              invert: false,
              channel: 0
          }
      },
      Settings: {
          scenes_dir: 'scenes',
          monitor_fps: false,
          max_over_sample: 6
      }
  }
end
