require_relative '../lib/utils'
require_relative '../../fitl/color/colors'

require_relative '../pixelator/story'
require_relative '../pixelator/scene'
require_relative '../pixelator/cue'
require_relative '../pixelator/layer'

class Assets
  include Utils
  include Colors

  def initialize(pixel_count: 10, settings: OpenStruct.new)
    @pixel_count = pixel_count
    @settings = settings
  end

  attr_reader :pixel_count, :settings

  MEDIA_CLASSES = [Layer, Cue, Scene, Story]

  MEDIA_TYPES = MEDIA_CLASSES.collect { |asset_class| asset_class.name.downcase.to_sym }

  BadMedia = Class.new(StandardError)

  MEDIA_CLASSES.each_with_index do |asset_class, i|
    media_type = MEDIA_TYPES[i]

    define_method "new_#{media_type}" do
      asset_class.new media_config
    end

    define_method "build_#{media_type}" do |name, config|
      begin
        asset_subclass = name.is_a?(Class) ? name : Object.const_get(name)
        if asset_subclass <= asset_class
          return asset_subclass.new media_config(config)
        else
          raise BadMedia, "#{asset_subclass} is not a #{asset_class.to_s.downcase}"
        end
      rescue NameError
        raise BadMedia, "No #{asset_class.to_s.downcase} called #{name}"
      end
    end

    define_method "load_#{media_type}" do |name|
      asset_class.new media_config(read_json(media_filename(media_type, name)))
    end

    define_method "save_#{media_type}" do |media|
      File.write media_filename(media_type, media.name), JSON.pretty_generate(media.to_h)
      media
    end
  end

  def media_config(config = {})
    {size: pixel_count, assets: self}.merge(config)
  end

  def media_filename(type, name)
    "#{media_locations[type]}/#{name}.json"
  end

  def media_locations
    @media_locations ||= settings.media_locations || DEFAULT_MEDIA_LOCATIONS
  end

  def reload_media_classes
    media_locations.each do |_, dir|
      Dir.glob("#{dir}/*.rb").each do |filename|
        load filename
      end
    end
  end

  DEFAULT_MEDIA_LOCATIONS = {story: 'assets/stories',
                             scene: 'assets/scenes',
                             cue: 'assets/cues',
                             layer: 'assets/layers'}
end
