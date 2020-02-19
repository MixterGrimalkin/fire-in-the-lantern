require_relative '../../neo_pixel/neo_pixel'
require_relative '../../pixelator/pixel'
require_relative '../../pixelator/pixelator'

RSpec.describe Pixel do

  let(:pixel_set) { Pixelator.new NeoPixel.new(10) }
  let(:neo_pixel) { pixel_set.neo_pixel }
  let(:px) { 8 }

  subject(:pixel) { pixel_set[px] }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:red) { Color.new 255,0,0 }

  it '.initialize off' do
    expect(pixel.color).to eq black
    expect(pixel.brightness).to eq 0
  end

  it '.set color and brightness' do
    pixel.set(white, 1.0)
    expect(pixel.color).to eq white
    expect(pixel.brightness).to eq 1.0
  end

  it '.get returns adjusted color' do
    pixel.color = Color.new(200, 100, 80, 4)
    pixel.brightness = 0.5
    expect(pixel.get).to eq Color.new(100, 50, 40, 2)
    pixel.color = Color.new(50, 100, 200)
    pixel.brightness = 0.2
    expect(pixel.get).to eq Color.new(10, 20, 40)
  end

end
