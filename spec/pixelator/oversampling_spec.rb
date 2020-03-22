require_relative '../../pixelator/pixelator'
require_relative '../../pixelator/layer'
require_relative '../../neo_pixel/neo_pixel'

RSpec.describe 'Oversampling for layer scroll' do

  let(:neo_pixel) { NeoPixel.new 6 }
  let(:pixelator) { Pixelator.new neo_pixel }
  let(:layer) { pixelator.scene.layer block: [1, 2] }

  let(:black) { Color.new }
  let(:color_25) { Color.new 50, 25, 20, 5 }
  let(:color_75) { Color.new 150, 75, 60, 15 }
  let(:color_full) { Color.new 200, 100, 80, 20 }

  let(:before_scroll) { [black, color_full, color_full, black, black, black] }
  let(:after_scroll_without_oversampling) { [black, black, color_full, color_full, black, black] }
  let(:after_scroll_with_oversampling) { [black, black, color_75, color_full, color_25, black] }

  before do
    layer.fill color_full
    pixelator.render
  end

  context 'without oversampling' do
    it 'scrolls by 1 pixel' do
      expect(neo_pixel.contents).to eq before_scroll
      layer.scroller.start 1
      layer.scroller.update 1.25
      pixelator.render
      expect(neo_pixel.contents).to eq after_scroll_without_oversampling
    end
  end

  context 'with 4x oversampling' do
    it 'scrolls by 1.25 effective pixels' do
      expect(neo_pixel.contents).to eq before_scroll
      layer.scroller.over_sample = 4
      layer.scroller.start 1
      layer.scroller.update 1.25
      pixelator.render
      expect(neo_pixel.contents).to eq after_scroll_with_oversampling
    end
  end
end