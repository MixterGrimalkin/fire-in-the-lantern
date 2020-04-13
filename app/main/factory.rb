class Factory
  include Utils

  def initialize(filename = '../.fitl.json')
    @filename = filename
    @config = read_config
  end

  attr_reader :filename, :config

  def neo
    @neo ||= neo_class.new(neo_config)
  end

  def px
    @px ||= Pixelator.new(px_config)
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
      symbolize_keys JSON.parse File.read filename
    else
      write_config DEFAULT_CONFIG
    end
  end

  def write_config(conf)
    File.write filename, JSON.pretty_generate(conf)
    conf
  end

  def neo_class
    Object.const_get(config.fetch(:Adapter))
  end

  def neo_key
    neo_class.name.to_sym
  end

  def neo_config
    config.fetch(:NeoPixel).merge(config.fetch(neo_key, {}))
  end

  def px_config
    config.fetch(:Pixelator).merge(neo_pixel: neo)
  end

  DEFAULT_CONFIG = {
      Adapter: 'OscNeoPixel',
      Pixelator: {
          render_period: 0.01,
          scenes_dir: 'scenes',
          default_crossfade: 1
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
      }
  }
end
