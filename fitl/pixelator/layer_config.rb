module LayerConfig

  def to_conf
    result = {
        canvas: canvas,
        background: background,
        opacity: opacity,
        visible: visible,
        contents: contents
    }
    if layer_scroller.last_updated
      result.merge!(layer_scroller: layer_scroller.to_conf)
    end
    if pattern_scroller.last_updated
      result.merge!(pattern_scroller: pattern_scroller.to_conf)
    end
    if fader.active?
      result.merge!(fader: fader.to_conf)
    end
    result
  end

  def from_conf(conf)
    @canvas = conf.fetch(:canvas)
    @background = conf.fetch(:background, nil)
    @opacity = conf.fetch(:opacity, 1.0)
    @visible = conf.fetch(:visible, true)
    @pattern = conf.fetch(:contents).collect { |string| ColorA.from_s(string) }
    layer_scroller.from_conf(conf[:layer_scroller]) if conf[:layer_scroller]
    pattern_scroller.from_conf(conf[:pattern_scroller]) if conf[:pattern_scroller]
    @modifiers = Fader.new(contents.size).from_conf(conf[:fader]) if conf[:fader]
    self
  end

end