require_relative '../lib/colors'

class Scene
  include Colors

  def initialize(pixel_count)
    @pixels = (0..(pixel_count-1)).to_a
    clear
  end

  def clear
    @layers = {}
    layer(:base, BLACK)
  end

  attr_reader :pixels, :layers

  def update
    layers.values.each(&:update)
  end

  def build_buffer
    layers.values.inject([BLACK]*pixels.size) do |buffer, layer|
      layer.render_over buffer
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

  def layer(layer_def, background = nil)
    key, criteria = key_criteria(layer_def)

    if criteria.nil?
      layer = Layer.new(pixels, background)
    else
      layer =
          Layer.new(pixels.select do |p|
            case criteria
              when Range, Array
                criteria.include?(p)
              when Proc
                criteria.call p
            end
          end, background)
    end

    self.class.send(:define_method, key, proc { layer })
    @layers[key] = layer
  end

  private

  def key_criteria(layer_def)
    if layer_def.is_a? Symbol
      [layer_def, nil]
    elsif layer_def.is_a?(Hash) && layer_def.size==1
      [layer_def.first[0].to_sym, layer_def.first[1]]
    else
      raise StandardError, 'Bad layer config'
    end
  end
end