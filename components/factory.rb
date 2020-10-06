require './components/pixelator'
require './components/assets'
require './components/osc/direct_osc_server'
require './lib/utils'

require 'json'

module Fitl
  class Factory
    include Utils

    def initialize(filename: DEFAULT_CONFIG_FILE, adapter_override: nil, disable_osc_hooks: false)
      @filename = filename
      @adapter_override = adapter_override
      @disable_osc_hooks = disable_osc_hooks
      reload
    end

    attr_reader :filename, :adapter_override, :disable_osc_hooks

    attr_accessor :config
    private :config=

    InvalidCommand = Class.new(StandardError)

    def reload
      self.config = read_config
      assets.reload_media_classes
      message "Loaded configuration from: #{filename}"
      self
    end

    def neo
      @neo ||= neo_class.new(neo_config)
    end

    def px
      @px ||= Pixelator.new(px_config)
    end

    def osc
      @osc ||= DirectOscServer.new(osc_config)
    end

    def layer
      px_media :layer
    end

    def cue
      px_media :cue
    end

    def scene
      px_media :scene
    end

    def story
      px_media :story
    end

    def px_media(type)
      raise InvalidCommand, "Pixelator is not in #{type} mode" unless px.send("#{type}_mode?")

      px.get
    end

    def assets
      @assets ||= Assets.new(
          pixel_count: neo.pixel_count,
          settings: settings
      )
    end

    def settings
      @settings ||= OpenStruct.new(config.fetch(:Settings, {}))
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
      neo_class.name.split('::').last.to_sym
    end

    def neo_config
      config.fetch(:Neopixel)
          .merge(config.fetch(neo_key, {}))
    end

    def px_config
      config.fetch(:Pixelator)
          .merge(neo_pixel: neo, assets: assets)
          .merge(disable_osc_hooks ? {osc_control_port: nil} : {})
    end

    def osc_config
      config.fetch(:DirectOscServer)
          .merge(neo_pixel: neo, assets: assets)
    end

    DEFAULT_CONFIG_FILE = 'fitl.json'

    DEFAULT_CONFIG = {
        Pixelator: {
            frame_rate: 30,
            osc_control_port: 3333
        },
        Neopixel: {
            pixel_count: 35,
            mode: :rgb,
        },
        Adapter: 'OscNeopixel',
        HttpNeopixel: {
            host: 'localhost',
            port: 4567,
            path: 'data'
        },
        OscNeopixel: {
            host: 'localhost',
            port: 3333,
            address: 'data'
        },
        WsNeopixel: {
            pin: 18,
            brightness: 255,
            options: {
                freq: 800_000,
                dma: 5,
                invert: false,
                channel: 0
            }
        },
        DirectOscServer: {
            port: 3333,
            address: 'data'
        },
        Settings: {
            default_media_type: 'cue',
            default_media_name: 'Daylight',
            media_locations: Assets::DEFAULT_MEDIA_LOCATIONS,
            auto_play: true,
            max_oversample: 6,
            allow_remote_reboot: false
        }
    }
  end
end
