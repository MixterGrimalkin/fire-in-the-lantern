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

  def read(scene, filename)
    json = symbolize_keys(JSON.parse(File.read(filename)))
    json[:layers].each do |layer_json|

      l = scene.layer(layer_json[:key].to_sym => layer_json[:pixels])

      layer_json[:contents].each_with_index do |color_string, i|
        comps = color_string[1..-2].split(',').collect(&:to_i)
        l[i] = Color.new(comps[0], comps[1], comps[2], comps[3])
      end
      l.global_opacity = layer_json[:opacity] || 1
      l.pixel_opacity = layer_json[:pixel_opacity] || ([1]*l.pixels.size)
      if (scroll = layer_json[:scroll])
        l.start_scroll scroll
      end

    end
    scene
  end

end
