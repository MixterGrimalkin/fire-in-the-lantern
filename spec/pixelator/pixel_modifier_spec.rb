require_relative '../../app/pixelator/pixelator'
require_relative '../../app/pixelator/layer'
require_relative '../../app/neo_pixel/neo_pixel'

RSpec.describe 'Pixel Modifiers' do

  let(:neo) { NeoPixel.new pixel_count: 5 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:layer) { px.scene.layer :a }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:white_50) { Color.new 127 }
  let(:red) { Color.new 255, 0, 0 }
  let(:red_50) { Color.new 127, 0, 0 }

  before do
    px.render
    expect(neo.contents)
        .to eq [black, black, black, black, black]
  end

  it 'fades entire layer in and out' do
    layer.set(1, red, 0)
    layer.set(2, white, 0)
    layer.set(3, red, 0)

    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.fade_in 1

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_50, white_50, red_50, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red, white, red, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red, white, red, black]

    layer.fade_out 1

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, red_50, white_50, red_50, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]

    layer.modifiers.update 0.5
    px.render
    expect(neo.contents).to eq [black, black, black, black, black]
  end

end