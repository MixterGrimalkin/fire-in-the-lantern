require_relative '../../fitl/color/tools'
require_relative '../../fitl/pixelator/layer'

include Colors

RSpec.describe Scroller do

  subject(:scroller) { Scroller.new 12, period: 0.5, oversample: 1 }

  let(:layer) { Layer.new 12, scroller: scroller }

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


# context 'Oversampling' do
#   let(:before_scroll) { [black, color_full, color_full, black, black, black] }
#   let(:after_scroll_without_oversampling) { [black, black, color_full, color_full, black, black] }
#   let(:after_scroll_with_oversampling) { [black, black, color_75, color_full, color_25, black] }
#   before do
#     layer.fill color_full
#     px.render
#   end
#   context 'without oversampling' do
#     it 'scrolls by 1 pixel' do
#       expect(neo.contents).to eq before_scroll
#       layer.layer_scroller.start 1
#       layer.layer_scroller.update 1.25
#       px.render
#       expect(neo.contents).to eq after_scroll_without_oversampling
#     end
#   end
#   context 'with 4x oversampling' do
#     it 'scrolls by 1.25 effective pixels' do
#       expect(neo.contents).to eq before_scroll
#       layer.layer_scroller.over_sample = 4
#       layer.layer_scroller.start 1
#       layer.layer_scroller.update 1.25
#       px.render
#       expect(neo.contents).to eq after_scroll_with_oversampling
#     end
#   end
# end
end