require_relative '../../fitl/color/colors'
require_relative '../../fitl/pixelator/layer'

include Colors

RSpec.describe Layer do

  subject(:layer) { Layer.new 4 }

  let(:base) { [BLACK, BLACK, BLACK, BLACK] }
  let(:blue_base) { [blue, blue, blue, blue] }

  let(:red) { Color.new 200, 0, 0 }
  let(:dk_red) { Color.new 100, 0, 0 }
  let(:dkr_red) { Color.new 50, 0, 0 }
  let(:red_a) { ColorA.new(red) }
  let(:red_a_50) { ColorA.new(red, 0.5) }
  let(:red_a_25) { ColorA.new(red, 0.25) }

  let(:blue) { Color.new 0, 0, 200 }
  let(:dk_blue) { Color.new 0, 0, 100 }
  let(:dkr_blue) { Color.new 0, 0, 50 }
  let(:blue_a) { ColorA.new(blue) }

  let(:purple) { Color.new 100, 0, 100 }

  it '.initialize' do
    expect(layer.opacity).to eq 1
    expect(layer.visible).to eq true
    expect(layer.to_a).to eq [EMPTY, EMPTY, EMPTY, EMPTY]
    expect(layer.color_array).to eq [nil, nil, nil, nil]
    expect(layer.alpha_array).to eq [1, 1, 1, 1]
    expect(layer.render_over(base)).to eq [BLACK, BLACK, BLACK, BLACK]
  end

  it '.[]' do
    expect(layer[1]).to eq EMPTY
    layer[0] = red
    layer.set 1, red, 0.5
    layer.set 2, red_a_50
    layer.set 3, red_a_50, 0.5
    expect(layer[1]).to eq red_a_50
    expect(layer.to_a).to eq [red_a, red_a_50, red_a_50, red_a_25]
    expect(layer.color_array).to eq [red, red, red, red]
    expect(layer.alpha_array).to eq [1.0, 0.5, 0.5, 0.25]
    expect(layer.render_over(base)).to eq [red, dk_red, dk_red, dkr_red]
  end

  it '.[] out of bounds' do
    expect { layer[4] }.to raise_error(PixelOutOfRangeError)
    expect { layer[-1] = red }.to raise_error(PixelOutOfRangeError)
    expect { layer.set 4, red }.to raise_error(PixelOutOfRangeError)
  end

  it '.fill Color' do
    layer.fill(red)
    expect(layer.to_a).to eq [red_a, red_a, red_a, red_a]
    expect(layer.render_over(base)).to eq [red, red, red, red]
  end

  it '.fill ColorA' do
    layer.fill(red_a)
    expect(layer.to_a).to eq [red_a, red_a, red_a, red_a]
    expect(layer.render_over(base)).to eq [red, red, red, red]
  end

  it '.fill faded ColorA' do
    layer.fill(red_a_50)
    expect(layer.to_a).to eq [red_a_50, red_a_50, red_a_50, red_a_50]
    expect(layer.render_over(base)).to eq [dk_red, dk_red, dk_red, dk_red]
  end

  it '.fill Color with alpha' do
    layer.fill(red, 0.5)
    expect(layer.to_a).to eq [red_a_50, red_a_50, red_a_50, red_a_50]
    expect(layer.render_over(base)).to eq [dk_red, dk_red, dk_red, dk_red]
  end

  it '.fill ColorA with alpha' do
    layer.fill(red_a_50, 0.5)
    expect(layer.to_a).to eq [red_a_25, red_a_25, red_a_25, red_a_25]
    expect(layer.render_over(base)).to eq [dkr_red, dkr_red, dkr_red, dkr_red]
  end

  it '.hide and .show' do
    layer.fill(red_a_50)
    layer.hide
    expect(layer.render_over(blue_base)).to eq [blue, blue, blue, blue]
    layer.show
    expect(layer.render_over(blue_base)).to eq [purple, purple, purple, purple]
    layer.visible = false
    expect(layer.render_over(blue_base)).to eq [blue, blue, blue, blue]
  end

  it '.opacity' do
    layer.fill(red)
    expect(layer.render_over(blue_base)).to eq [red, red, red, red]
    layer.opacity = 0.5
    expect(layer.render_over(blue_base)).to eq [purple, purple, purple, purple]
  end

  it '.draw and .clear' do
    layer.draw [red_a, blue, blue, red]
    expect(layer.render_over(base)).to eq [red, blue, blue, red]

    layer.draw [dk_blue, dk_blue, blue], 2
    expect(layer.render_over(base)).to eq [red, blue, dk_blue, dk_blue]

    layer.draw [purple, purple, purple], -2
    expect(layer.render_over(base)).to eq [purple, blue, dk_blue, dk_blue]

    layer.clear
    expect(layer.render_over(base)).to eq base
  end

  it 'pre-fills a layer' do
    layer = Layer.new 3, fill: red
    expect(layer.to_a).to eq [red_a, red_a, red_a]
    layer = Layer.new 3, fill: blue_a
    expect(layer.to_a).to eq [blue_a, blue_a, blue_a]
  end

  it 'renders with canvas' do
    layer.fill red
    expect(layer.render_over blue_base, canvas: [1, 2])
        .to eq [blue, red, red, blue]
  end

end