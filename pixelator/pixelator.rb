require_relative '../support/color'
require_relative '../support/color_constants'
require_relative 'layer'

require 'json'

class Pixelator
  include ColorConstants

  def initialize(neo_pixel)
    @neo_pixel = neo_pixel
    @pixels = (0..(pixel_count-1)).to_a
    @started = false
    @render_thread = nil
    clear
  end

  def clear
    @layers = {}
    layer(:base, BLACK)
    render
  end

  def pixel_count
    neo_pixel.pixel_count
  end

  attr_reader :neo_pixel, :pixels, :started, :layers

  def start(period = 0.01)
    raise NotAllowed if @started

    @started = true

    @render_thread = Thread.new do
      while @started
        @layers.values.each(&:update)
        render
        sleep period
      end
    end
  end

  def stop
    raise NotAllowed unless @started

    @started = false
    @render_thread.join
  end

  def all_on
    stop if started
    neo_pixel.all_on
  end

  def all_off
    stop if started
    neo_pixel.all_off
  end

  def render
    neo_pixel.contents = build_buffer
    neo_pixel.render
  end

  def build_buffer
    buffer = [BLACK] * pixel_count
    @layers.each do |_, layer|
      buffer = layer.render_over buffer
    end
    buffer
  end

  def layer(layer_def, background = nil)
    if layer_def.is_a? Symbol
      key = layer_def
      layer = Layer.new(key, pixels, background)

    elsif layer_def.is_a?(Hash) && layer_def.size==1
      key, criteria = layer_def.first[0].to_sym, layer_def.first[1]
      layer =
          Layer.new(key, pixels.select do |p|
            case criteria
              when Range, Array
                criteria.include?(p)
              when Proc
                criteria.call p
            end
          end, background)

    else
      return
    end

    self.class.send(:define_method, key, proc { layer })
    @layers[key] = layer
  end

  def []=(key, value)
    case key
      when Integer
        return unless value.is_a? Color
        @layers[:base][key] = value
      when Symbol
        return unless value.is_a? Layer
        @layers[key] = value
      else
        nil
    end
  end

  def [](key)
    case key
      when Integer
        @layers[:base][key]
      when Symbol
        @layers[key]
      else
        nil
    end
  end

  def save_scene(filename)
    json =
        {layers:
             layers.collect do |_, layer|
               layer.layer_def
             end
        }.to_json
    File.write(filename, json)
  end

  def load_scene(filename)
    clear
    json = JSON.parse(File.read(filename))
    json['layers'].each do |layer_json|
      l = layer layer_json['key'].to_sym => layer_json['pixels']
      layer_json['contents'].each_with_index do |color_string, i|
        comps = color_string[1..-2].split(',').collect(&:to_i)
        l[i] = Color.new(comps[0], comps[1], comps[2], comps[3])
      end
      l.opacity = layer_json['opacity']
      if (scroll = layer_json['scroll'])
        l.start_scroll scroll
      end
    end
    render
  end

end

NotAllowed = Class.new(StandardError)
