require_relative '../../app/pixelator/pixelator'
require_relative '../../app/pixelator/layer'
require_relative '../../app/neo_pixel/neo_pixel'

RSpec.describe 'Oversampling for layer scroll' do

  let(:neo) { NeoPixel.new pixel_count: 6 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:layer) { px.scene.layer block: [1, 2] }

  let(:black) { Color.new }
  let(:color_25) { Color.new 50, 25, 20, 5 }
  let(:color_75) { Color.new 150, 75, 60, 15 }
  let(:color_full) { Color.new 200, 100, 80, 20 }

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