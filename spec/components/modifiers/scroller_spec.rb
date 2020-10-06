require_relative '../../fitl/color/pen'
require_relative '../../fitl/pixelator/layer'

include Colors

RSpec.describe Scroller do

  subject(:scroller) { Scroller.new size: layer_size, period: 0.5, oversample: 1 }

  let(:layer) { Layer.new size: layer_size, scroller: scroller }

  let(:layer_size) { 12 }

  let(:canvas_size) { 6 }
  let(:blue_base) { [blue] * canvas_size }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }

  let(:color_25) { Color.new 50, 25, 20, 5 }
  let(:color_75) { Color.new 150, 75, 60, 15 }
  let(:color_full) { Color.new 200, 100, 80, 20 }

  before do
    layer.draw Tools.blocks(
        red, 4, nil, 1, red, 3, nil, 2, red, 1, nil, 1
    )
  end

  it 'initializes' do
    expect(layer.color_array)
        .to eq [red, red, red, red, nil, red, red, red, nil, nil, red, nil]
    expect(layer.render_over(blue_base))
        .to eq [red, red, red, red, blue, red]
    expect(layer.scroller).to eq scroller
    expect(scroller.size).to eq 12
    expect(scroller.effective_size).to eq 12
    expect(scroller.period).to eq 0.5
    expect(scroller.effective_period).to eq 0.5
    expect(scroller.oversample).to eq 1
    expect(scroller.active).to eq false
    expect(scroller.offset).to eq 0
  end

  it 'does not scroll while stopped' do
    scroller.update(1)
    expect(scroller.offset).to eq 0
    expect(layer.render_over(blue_base))
        .to eq [red, red, red, red, blue, red]
  end

  it 'scrolls forwards' do
    scroller.start
    expect(scroller.active).to eq true

    scroller.update(1)
    expect(scroller.offset).to eq 2
    expect(layer.render_over(blue_base))
        .to eq [red, blue, red, red, red, red]

    scroller.update(2.5)
    expect(scroller.offset).to eq 7
    expect(layer.render_over(blue_base))
        .to eq [red, red, red, blue, blue, red]

    scroller.stop

    scroller.update(3)
    expect(scroller.offset).to eq 7
    expect(layer.render_over(blue_base))
        .to eq [red, red, red, blue, blue, red]
  end

  it 'scrolls backwards' do
    scroller.start
    scroller.period = -0.5

    scroller.update(1)
    expect(scroller.offset).to eq -2
    expect(layer.render_over(blue_base))
        .to eq [red, red, blue, red, red, red]

    scroller.update(2.5)
    expect(scroller.offset).to eq -7
    expect(layer.render_over(blue_base))
        .to eq [red, blue, blue, red, blue, red]
  end

  it 'scroller controlled from layer' do
    layer.scroll -0.5
    expect(scroller.active).to eq true

    scroller.update(1)
    expect(scroller.offset).to eq -2
    expect(layer.render_over(blue_base))
        .to eq [red, red, blue, red, red, red]

    layer.stop_scroll
    expect(scroller.active).to eq false

    scroller.update(1)
    expect(scroller.offset).to eq -2
    expect(layer.render_over(blue_base))
        .to eq [red, red, blue, red, red, red]
  end

  it 'resets offset when scroll loops forwards' do
    scroller.start
    scroller.update 24.5
    expect(scroller.offset).to eq 1
    expect(layer.render_over(blue_base))
        .to eq [blue, red, red, red, red, blue]
  end

  it 'resets offset when scroll loops backwards' do
    scroller.start
    scroller.period = -0.5
    scroller.update 24.5
    expect(scroller.offset).to eq -1
    expect(layer.render_over(blue_base))
        .to eq [red, red, red, blue, red, red]
  end

  context 'Oversampling' do
    let(:layer_size) { 6 }

    let(:before_scroll) { [black, color_full, color_full, black, black, black] }
    let(:after_scroll_without_oversampling) { [black, black, color_full, color_full, black, black] }
    let(:after_scroll_with_oversampling) { [black, black, color_75, color_full, color_25, black] }

    it 'scrolls without oversampling' do
      layer.draw(before_scroll)
      expect(layer.render_over(blue_base))
          .to eq before_scroll

      scroller.start
      scroller.period = 1
      scroller.update 1.25

      expect(scroller.offset).to eq 1
      expect(layer.render_over(blue_base))
          .to eq after_scroll_without_oversampling
    end

    it 'scrolls with oversampling' do
      layer.draw(before_scroll)
      expect(layer.render_over(blue_base))
          .to eq before_scroll

      scroller.start
      scroller.period = 1
      scroller.oversample = 4
      expect(scroller.effective_period).to eq 0.25
      expect(scroller.effective_size).to eq 24

      scroller.update 1.25

      expect(scroller.offset).to eq 5
      expect(layer.render_over(blue_base))
          .to eq after_scroll_with_oversampling

      scroller.oversample = 10
      expect(scroller.effective_period).to eq 0.1
      expect(scroller.effective_size).to eq 60
      expect(scroller.offset).to eq 12
    end
  end
end
