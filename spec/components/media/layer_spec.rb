require './main/requirer'
include Fitl
include Colours

RSpec.describe Layer do

  subject(:layer) { Layer.new size: 4 }

  let(:base) { [BLACK, BLACK, BLACK, BLACK] }
  let(:blue_base) { [blue, blue, blue, blue] }

  let(:red) { Colour.new 200, 0, 0 }
  let(:dk_red) { Colour.new 100, 0, 0 }
  let(:dkr_red) { Colour.new 50, 0, 0 }
  let(:red_a) { red }
  let(:red_a_50) { ColourA.new(red, 0.5) }
  let(:red_a_25) { ColourA.new(red, 0.25) }

  let(:blue) { Colour.new 0, 0, 200 }
  let(:dk_blue) { Colour.new 0, 0, 100 }
  let(:dkr_blue) { Colour.new 0, 0, 50 }
  let(:blue_a) { ColourA.new(blue) }

  let(:purple) { Colour.new 100, 0, 100 }

  it '.initialize' do
    expect(layer.opacity).to eq 1
    expect(layer.visible).to eq true
    expect(layer.to_a).to eq [EMPTY, EMPTY, EMPTY, EMPTY]
    expect(layer.Colour_array).to eq [nil, nil, nil, nil]
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
    expect(layer.render_over(base)).to eq [red, dk_red, dk_red, dkr_red]
  end

  it '.[] out of bounds' do
    expect { layer[4] }.to raise_error(PixelOutOfRangeError)
    expect { layer[-1] = red }.to raise_error(PixelOutOfRangeError)
    expect { layer.set 4, red }.to raise_error(PixelOutOfRangeError)
  end

  it '.fill Colour' do
    layer.fill(red)
    expect(layer.to_a).to eq [red_a, red_a, red_a, red_a]
    expect(layer.render_over(base)).to eq [red, red, red, red]
  end

  it '.fill ColourA' do
    layer.fill(red_a)
    expect(layer.to_a).to eq [red_a, red_a, red_a, red_a]
    expect(layer.render_over(base)).to eq [red, red, red, red]
  end

  it '.fill faded ColourA' do
    layer.fill(red_a_50)
    expect(layer.to_a).to eq [red_a_50, red_a_50, red_a_50, red_a_50]
    expect(layer.render_over(base)).to eq [dk_red, dk_red, dk_red, dk_red]
  end

  it '.fill Colour with alpha' do
    layer.fill(red, 0.5)
    expect(layer.to_a).to eq [red_a_50, red_a_50, red_a_50, red_a_50]
    expect(layer.render_over(base)).to eq [dk_red, dk_red, dk_red, dk_red]
  end

  it '.fill ColourA with alpha' do
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
    layer = Layer.new size: 3, fill: red
    expect(layer.to_a).to eq [red_a, red_a, red_a]
    layer = Layer.new size: 3, fill: blue_a
    expect(layer.to_a).to eq [blue_a, blue_a, blue_a]
  end

  it 'renders with canvas' do
    layer.fill red
    expect(layer.render_over blue_base, canvas: [1, 2])
        .to eq [blue, red, red, blue]
    expect(layer.render_over blue_base, canvas: [0, 4, 5])
        .to eq [red, blue, blue, blue]
    expect(layer.render_over blue_base, canvas: [-2, 8])
        .to eq [blue, blue, red, blue]
  end

end
