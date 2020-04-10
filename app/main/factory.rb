require_relative '../pixelator/pixelator'

require_relative '../neo_pixel/neo_pixel'
require_relative '../neo_pixel/ws_neo_pixel'
require_relative '../neo_pixel/osc_neo_pixel'
require_relative '../neo_pixel/http_neo_pixel'
require_relative '../neo_pixel/text_neo_pixel'

require_relative '../lib/color'
require_relative '../lib/color_a'
require_relative '../lib/color_tools'
require_relative '../lib/utils'

require 'json'

class Factory
  include Utils

  def initialize(filename = '../.fitl.json')
    @filename = filename
    @config = load_config
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
    File.write filename, config.to_json
  end

  private

  def load_config
    write_defaults unless File.exists? filename
    symbolize_keys JSON.parse File.read filename
  end

  def write_defaults
    File.write filename, DEFAULT_CONFIG.to_json
  end

  def neo_class
    Object.const_get(config.fetch(:Adapter))
  end

  def neo_key
    neo_class.name.to_sym
  end

  def neo_config
    config[:NeoPixel].merge(config[neo_key] || {})
  end

  def px_config
    config[:Pixelator].merge(neo_pixel: neo)
  end

  DEFAULT_CONFIG = {
      Adapter: 'OscNeoPixel',
      Pixelator: {
          render_period: 0.01,
          scenes_dir: 'scenes'
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
          brightness: 127,
          options: {
              freq: 800_000,
              dma: 5,
              invert: false,
              channel: 0
          }
      }
  }
end
