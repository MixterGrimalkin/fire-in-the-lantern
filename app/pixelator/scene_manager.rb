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

      l.pattern = layer_json[:contents].collect do |color_a_string|
        ColorA.from_s color_a_string
      end
      l.opacity = layer_json[:opacity] || 1
      if (scroll = layer_json[:scroll])
        l.layer_scroller.over_sample = (layer_json[:scroll_over_sample]||1).to_i
        l.layer_scroller.start scroll
      end

    end
    scene
  end

end
