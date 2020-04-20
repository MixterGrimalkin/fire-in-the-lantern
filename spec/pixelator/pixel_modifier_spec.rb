require_relative '../../fitl/pixelator/pixelator'
require_relative '../../fitl/pixelator/layer'
require_relative '../../fitl/neo_pixel/neo_pixel'

RSpec.describe 'Pixel Modifiers' do

  let(:neo) { NeoPixel.new pixel_count: 5 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:layer) { px.scene.layer :a }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:white_50) { Color.new 127 }
  let(:white_25) { Color.new 63 }
  let(:red) { Color.new 255, 0, 0 }
  let(:red_50) { Color.new 127, 0, 0 }
  let(:red_25) { Color.new 63, 0, 0 }
  let(:red_12) { Color.new 31, 0, 0 }

  before do
    px.render
    expect(neo.contents)
        .to eq [black, black, black, black, black]
  end

  it 'knows if it is active' do
    expect(layer.modifiers.active?).to eq false
    layer.fade_in 1
    expect(layer.modifiers.active?).to eq true
  end

  it 'fades entire layer in and out' do
    layer.fade_out
    layer.set(1, red)
    layer.set(2, white)
    layer.set(3, red, 0.5)

    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.fade_in 1

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_50, white_50, red_25, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red, white, red_50, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red, white, red_50, black]

    layer.fade_out 1

    px.render
    expect(neo.contents).to eq [black, red, white, red_50, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_50, white_50, red_25, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]
  end

  it 'bounce fades the layer' do
    layer.fade_out
    layer.set(1, red)
    layer.set(2, white)
    layer.set(3, red, 0.5)

    layer.fade_in 1, max: 0.5, bounce: true
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_25, white_25, red_12, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_50, white_50, red_25, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_25, white_25, red_12, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_25, white_25, red_12, black]
  end

end