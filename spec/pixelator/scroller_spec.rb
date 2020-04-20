require_relative '../../fitl/pixelator/pixelator'
require_relative '../../fitl/pixelator/layer'
require_relative '../../fitl/neo_pixel/neo_pixel'

RSpec.describe Scroller do

  let(:neo) { NeoPixel.new pixel_count: 6 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:layer) { px.scene.layer :block, canvas: [1, 2] }
  let(:big_layer) { px.scene.layer :big, size: 12 }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:color_25) { Color.new 50, 25, 20, 5 }
  let(:color_75) { Color.new 150, 75, 60, 15 }
  let(:color_full) { Color.new 200, 100, 80, 20 }

  let(:red) { Color.new 255, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }

  it 'scrolls layer' do
    layer.fill color_full

    layer.layer_scroller.update 1
    px.render
    expect(neo.contents)
        .to eq [black, color_full, color_full, black, black, black]

    layer.layer_scroller.start 1
    layer.layer_scroller.update 4.5
    px.render
    expect(neo.contents)
        .to eq [color_full, black, black, black, black, color_full]

    layer.layer_scroller.start -2
    layer.layer_scroller.update 6.5
    px.render
    expect(neo.contents)
        .to eq [black, black, color_full, color_full, black, black]
  end

  it 'scrolls pattern' do
    big_layer.set_range (0..3), red
    big_layer.set_range (5..7), blue
    big_layer.set 10, white

    px.render
    expect(neo.contents)
        .to eq [red, red, red, red, black, blue]

    big_layer.pattern_scroller.start -1

    px.render
    expect(neo.contents)
        .to eq [red, red, red, red, black, blue]

    big_layer.pattern_scroller.update 3

    px.render
    expect(neo.contents)
        .to eq [red, black, blue, blue, blue, black]

    big_layer.pattern_scroller.update 4

    px.render
    expect(neo.contents)
        .to eq [blue, black, black, white, black, red]
  end

  context 'does not increase offset forever' do
    it 'works when scrolling forward' do
      layer.fill red
      px.render
      expect(neo.contents)
          .to eq [black, red, red, black, black, black]

      layer.layer_scroller.start 1
      layer.layer_scroller.update 10
      px.render
      expect(neo.contents)
          .to eq [red, black, black, black, black, red]

      expect(layer.layer_scroller.offset).to eq 4
    end
    it 'works when scrolling backwards' do
      layer.fill red
      px.render
      expect(neo.contents)
          .to eq [black, red, red, black, black, black]

      layer.layer_scroller.start -1
      layer.layer_scroller.update 10
      px.render
      expect(neo.contents)
          .to eq [black, black, black, red, red, black]

      expect(layer.layer_scroller.offset).to eq -4
    end
  end

  context 'Oversampling' do
    let(:before_scroll) { [black, color_full, color_full, black, black, black] }
    let(:after_scroll_without_oversampling) { [black, black, color_full, color_full, black, black] }
    let(:after_scroll_with_oversampling) { [black, black, color_75, color_full, color_25, black] }
    before do
      layer.fill color_full
      px.render
    end
    context 'without oversampling' do
      it 'scrolls by 1 pixel' do
        expect(neo.contents).to eq before_scroll
        layer.layer_scroller.start 1
        layer.layer_scroller.update 1.25
        px.render
        expect(neo.contents).to eq after_scroll_without_oversampling
      end
    end
    context 'with 4x oversampling' do
      it 'scrolls by 1.25 effective pixels' do
        expect(neo.contents).to eq before_scroll
        layer.layer_scroller.over_sample = 4
        layer.layer_scroller.start 1
        layer.layer_scroller.update 1.25
        px.render
        expect(neo.contents).to eq after_scroll_with_oversampling
      end
    end
  end
end