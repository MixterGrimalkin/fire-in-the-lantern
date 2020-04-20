module SceneConfig

  def to_conf
    {
        layers:
            layers.collect do |key, layer|
              {key: key}.merge(layer.to_conf)
            end
    }
  end

  def from_conf(conf)
    conf[:layers].each do |layer_conf|
      layer(layer_conf[:key].to_sym).from_conf(layer_conf)
    end
  end

end