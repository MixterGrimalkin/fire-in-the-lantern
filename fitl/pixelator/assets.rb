require_relative '../lib/utils'
require_relative '../../fitl/color/colors'

require_relative 'story'
require_relative 'scene'
require_relative 'cue'
require_relative 'layer'

class Assets
  include Utils
  include Colors

  def initialize(pixel_count: 10, settings: OpenStruct.new)
    @pixel_count = pixel_count
    @settings = settings
  end

  attr_reader :pixel_count, :settings

  def base_layer
    @base_layer ||= [BLACK] * pixel_count
  end

  def new_media_name(type)
    @counters ||= {}
    @counters[type] ||= 0
    @counters[type] += 1
    "#{type}_#{@counters[type]}"
  end

  MEDIA_CLASSES = [Layer, Cue, Scene, Story]

  MEDIA_TYPES = MEDIA_CLASSES.collect { |asset_class| asset_class.name.downcase.to_sym }

  def media_config(config = {})
    {size: pixel_count, assets: self}.merge(config)
  end

  MEDIA_CLASSES.each_with_index do |asset_class, i|
    media_type = MEDIA_TYPES[i]

    define_method "new_#{media_type}" do
      asset_class.new media_config
    end

    define_method "build_#{media_type}" do |name, config|
      begin
        asset_subclass = name.is_a?(Class) ? name : Object.const_get(name)
        if asset_subclass < asset_class
          return asset_subclass.new media_config(config)
        end
      rescue NameError
        # ignored
      end
      asset_class.new media_config(config)
    end

    define_method "load_#{media_type}" do |name|
      asset_class.new media_config(read_json(media_filename(media_type, name)))
    end

    define_method "save_#{media_type}" do |media|
      File.write media_filename(media_type, media.name), JSON.pretty_generate(media.to_h)
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
