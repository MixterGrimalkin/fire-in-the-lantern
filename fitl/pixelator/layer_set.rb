require_relative '../color/colors'
require_relative 'layer'

module LayerSet
  attr_accessor :layer_register

  def reset_layers
    self.layer_register = {}
  end

  def update_layers
    layers.each(&:update)
  end

  # Access layer register

  def layers
    layer_register.values.collect { |entry| entry[:layer] }
  end

  def layer(key)
    check_layer! key
    layer_register[key][:layer]
  end

  # Add layers

  def add_layer(layer, canvas: nil, external: false)
    layer_register[unique_name(layer)] = {
        layer: layer,
        canvas: canvas&.to_a,
        external: external
    }
    layer
  end

  def build_layer(layer_class = Layer, canvas: nil, config: {})
    add_layer assets.build_layer(layer_class, config), canvas: canvas, external: false
  end

  def import_layer(name, canvas: nil)
    add_layer assets.load_layer(name), canvas: canvas, external: false
  end

  def link_layer(name, canvas: nil)
    add_layer assets.load_layer(name), canvas: canvas, external: true
  end

  def apply_canvas(layer_key, canvas = nil)
    layer_register[layer_key][:canvas] = canvas
  end

  # Switch external

  def link_out(key)
    check_layer! key, false
    entry = layer_register[key]
    assets.save_layer entry[:layer].name, entry[:layer]
    entry[:external] = true
  end

  def copy_in(key)
    check_layer! key, true
    layer_register[key][:external] = false
  end

  # Visibility

  def hide_all
    layers.each(&:hide)
  end

  def show_all
    layers.each(&:show)
  end

  def solo(layer_key)
    check_layer! layer_key
    hide_all
    layer(layer_key).show
  end

  # Ordering

  def put_top(layer_key)
    check_layer! layer_key

    new_layers = {}
    layer_register.each do |key, entry|
      new_layers[key] = entry unless key==layer_key
    end
    new_layers[layer_key] = layer_register[layer_key]
    self.layer_register = new_layers
  end

  def put_bottom(layer_key)
    check_layer! layer_key

    new_layers = {layer_key => layer_register[layer_key]}
    layer_register.each do |key, entry|
      new_layers[key] = entry unless key==layer_key
    end
    self.layer_register = new_layers
  end

  private

  def unique_name(layer)
    name = layer.name.to_s
    if name[-1] == '_'
      name = "#{name}1"
    end
    counter = 1
    while check_layer(name)
      name = "#{name}_#{counter += 1}"
    end
    layer.name = name
    name.to_sym
  end

  def check_layer(key, external = nil)
    return false unless layer_register[key.to_sym]

    external.nil? || (external == layer_register[key.to_sym][:external])
  end

  def check_layer!(key, external = nil)
    raise LayerNotFound, "#{key.to_s}#{
    if external.nil?
      ''
    else
      "#{external ? ':linked' : ':embedded'}"
    end}" unless check_layer(key, external)
  end

  LayerNotFound = Class.new(StandardError)
end

