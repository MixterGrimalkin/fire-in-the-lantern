require_relative 'scene'

module SceneManager

  def write(scene, filename)
    json =
        {layers:
             scene.layers.collect do |key, layer|
               {key: key}.merge(layer.layer_def)
             end
        }.to_json
    File.write(filename, json)
  end

  def read(pixel_count, filename)
    scene = Scene.new pixel_count
    json = symbolize_keys(JSON.parse(File.read(filename)))
    json[:layers].each do |layer_json|

      l = scene.layer(layer_json[:key].to_sym => layer_json[:pixels])

      layer_json[:contents].each_with_index do |color_string, i|
        comps = color_string[1..-2].split(',').collect(&:to_i)
        l[i] = Color.new(comps[0], comps[1], comps[2], comps[3])
      end
      l.layer_opacity = layer_json[:opacity] || 1
      l.pixel_opacity = layer_json[:pixel_opacity] || ([1]*l.pixels.size)
      if (scroll = layer_json[:scroll])
        l.scroller.over_sample = (layer_json[:scroll_over_sample]||1).to_i
        l.scroller.start scroll
      end

    end
    scene
  end

end
