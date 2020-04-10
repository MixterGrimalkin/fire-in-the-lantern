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

  before do
    px.render
    expect(neo.contents)
        .to eq [black, black, black, black, black]
  end

  it 'fades in a single pixel' #do
    # layer.fade_in 2, 1, white, 1.0
    #
    # layer.modifiers.update 0.5
    # px.render
    # expect(neo.contents)
    #     .to eq [black, black, white_50, black, black]
    #
    # layer.modifiers.update 0.5
    # px.render
    # expect(neo.contents)
    #     .to eq [black, black, white, black, black]
    #
    # layer.modifiers.update 0.5
    # px.render
    # expect(neo.contents)
    #     .to eq [black, black, white, black, black]
  # end

end