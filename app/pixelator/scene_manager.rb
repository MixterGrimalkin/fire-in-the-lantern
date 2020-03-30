require_relative 'scene'

module SceneManager

  SCENES_DIR = ENV['SCENES_DIR'] || 'scenes'

  def write(scene, filename)
    json =
        {layers:
             scene.layers.collect do |key, layer|
               {key: key}.merge(layer.to_conf)
             end
        }.to_json
    File.write("#{SCENES_DIR}/#{filename}", json)
  end

  def read(pixel_count, filename)
    scene = Scene.new pixel_count
    json = symbolize_keys(JSON.parse(File.read("#{SCENES_DIR}/#{filename}")))
    json[:layers].each do |layer_json|
      scene.layer(layer_json[:key].to_sym => layer_json[:canvas]).from_conf(layer_json)
    end
    scene
  end

end
