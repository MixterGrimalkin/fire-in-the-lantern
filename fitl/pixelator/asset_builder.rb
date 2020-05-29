require_relative '../lib/utils'

require_relative 'story'
require_relative 'scene'
require_relative 'cue'
require_relative 'layer'

class AssetBuilder
  include Utils

  ASSET_CLASSES = [Layer, Cue, Scene, Story]

  def initialize(default_size:, settings: OpenStruct.new)
    @default_size = default_size
    @settings = settings
  end

  ASSET_TYPES = ASSET_CLASSES.collect { |asset_class| asset_class.name.downcase.to_sym }

  ASSET_CLASSES.each_with_index do |asset_class, i|
    asset_type = ASSET_TYPES[i]

    define_method "new_#{asset_type}" do
      asset_class.new size: default_size, settings: settings
    end

    define_method "build_#{asset_type}" do |config|
      asset_class.new({settings: settings}.merge(config))
    end

    define_method "load_#{asset_type}" do |name|
      asset_class.new({settings: settings}.merge(read_json filename(asset_type, name)))
    end

    define_method "save_#{asset_type}" do |name, asset|
      File.write filename(asset_type, name), JSON.pretty_generate(asset.to_h)
      asset
    end
  end

  def filename(type, name)
    "#{asset_locations[type]}/#{name}.json"
  end

  private

  attr_reader :default_size, :settings

  def asset_locations
    @asset_locations ||=
        settings.asset_locations || {
            story: 'stories',
            scene: 'scenes',
            cue: 'cues',
            layer: 'layers',
        }
  end
end
