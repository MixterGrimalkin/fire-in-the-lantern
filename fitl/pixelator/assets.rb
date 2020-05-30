require_relative '../lib/utils'

require_relative 'story'
require_relative 'scene'
require_relative 'cue'
require_relative 'layer'

class Assets
  include Utils

  def initialize(default_size: 10, settings: OpenStruct.new)
    @default_size = default_size
    @settings = settings
  end

  attr_accessor :default_size, :settings

  MEDIA_CLASSES = [Layer, Cue, Scene, Story]

  MEDIA_TYPES = MEDIA_CLASSES.collect { |asset_class| asset_class.name.downcase.to_sym }

  MEDIA_CLASSES.each_with_index do |asset_class, i|
    media_type = MEDIA_TYPES[i]

    define_method "new_#{media_type}" do
      asset_class.new size: default_size, assets: self
    end

    define_method "build_#{media_type}" do |config|
      asset_class.new(config.merge(assets: self))
    end

    define_method "load_#{media_type}" do |name|
      asset_class.new(read_json(media_filename(media_type, name)).merge(assets: self))
    end

    define_method "save_#{media_type}" do |name, media|
      File.write media_filename(media_type, name), JSON.pretty_generate(media.to_h)
      media
    end
  end

  def media_filename(type, name)
    "#{media_locations[type]}/#{name}.json"
  end

  def media_locations
    @media_locations ||=
        (settings.media_locations || {story: 'stories',
                                      scene: 'scenes',
                                      cue: 'cues',
                                      layer: 'layers'}
        )
  end
end
