module LayerConfig

  def to_conf
    result = {
        canvas: canvas,
        background: background,
        opacity: opacity,
        visible: visible,
        pattern: pattern
    }
    if layer_scroller.last_updated
      result.merge!(layer_scroller: layer_scroller.to_conf)
    end
    if pattern_scroller.last_updated
      result.merge!(pattern_scroller: pattern_scroller.to_conf)
    end
    result
  end

  def from_conf(conf)
    @canvas = conf.fetch(:canvas)
    @background = conf.fetch(:background, nil)
    @opacity = conf.fetch(:opacity, 1.0)
    @visible = conf.fetch(:visible, true)
    @pattern = conf.fetch(:pattern).collect { |string| ColorA.from_s(string) }
    @modifiers = Modifiers.new pattern.size
    layer_scroller.from_conf(conf[:layer_scroller]) if conf[:layer_scroller]
    pattern_scroller.from_conf(conf[:pattern_scroller]) if conf[:pattern_scroller]
  end

end