require_relative '../../neo_pixel/neo_pixel'
require_relative '../../pixelator/pixelator'
require 'byebug'

RSpec.describe Pixelator do

  subject(:pixelator) { Pixelator.new NeoPixel.new(10) }

  let(:neo_pixel) { pixelator.neo_pixel }

  let(:px) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] }

  let(:black) { Color.new }
  let(:red) { Color.new 255,0,0 }
  let(:blue) { Color.new 0,0,255 }
  let(:orange) { Color.new 200,180,0 }
  let(:dim_orange) { Color.new 100,90,0 }

  it 'initializes pixels' do
    expect(pixelator.pixel_count).to eq 10
    expect(pixelator.pixels).to eq px
  end
  
  it 'initializes the base layer' do
    expect(pixelator[:base].pixels).to eq px
    expect(pixelator.base.pixels).to eq px
    expect(pixelator.base.contents).to eq [black]*10
  end

  it 'can define a new layer' do
    pixelator.layer :the_lot
    expect(pixelator.the_lot.pixels).to eq px
  end

  it 'can define a layer by range' do
    pixelator.layer mid_four: (4..7)
    expect(pixelator[:mid_four].pixels)
        .to eq [px[4], px[5], px[6], px[7]]
  end

  it 'can define a layer by array' do
    pixelator.layer those_three: [1, 6, 9]
    expect(pixelator[:those_three].pixels)
        .to eq [px[1], px[6], px[9]]
  end

  it 'can define a layer by proc' do
    pixelator.layer evens: proc { |p| p % 2 == 0 }
    expect(pixelator[:evens].pixels)
        .to eq [px[0], px[2], px[4], px[6], px[8]]
  end

  it 'defines a method for new layers' do
    pixelator.layer odds: proc { |p| p % 2 != 0 }
    expect(pixelator.odds).to eq pixelator[:odds]
  end

  it 'can combine layers' do
    pixelator.layer left: (0..4)
    pixelator.layer right: (5..9)
    pixelator[:sum] = pixelator[:left] + pixelator[:right]
    expect(pixelator[:sum].pixels).to eq px
  end

  it 'can subtract layers' do
    pixelator.layer left: (0..4)
    pixelator.layer right: (5..9)
    pixelator[:diff] = pixelator[:base] - pixelator[:right]
    expect(pixelator[:diff]).to eq pixelator[:left]
  end

  it 'renders to NeoPixel' do
    expect(neo_pixel).to receive(:show).once
    pixelator[0] = red
    pixelator[1] = blue
    pixelator[2] = black
    pixelator[3] = blue
    pixelator[4] = red
    pixelator[5] = orange
    pixelator[6] = orange.with_brightness 0.5
    pixelator[7] = black
    pixelator[8] = blue
    pixelator[9] = red
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [red, blue, black, blue, red, orange, dim_orange, black, blue, red]
  end

  context '.start and .stop' do
    it 'starts and stops the rendering thread' do
      expect_any_instance_of(NeoPixel).to receive(:show).twice
      expect(pixelator.started).to eq false
      pixelator.start 0.25
      expect(pixelator.started).to eq true
      sleep 0.5
      pixelator.stop
      expect(pixelator.started).to eq false
      sleep 0.5
    end
    it 'raises error if already started' do
      pixelator.start
      expect { pixelator.start }.to raise_error NotAllowed
    end
    it 'raises error if already stopped' do
      expect { pixelator.stop }.to raise_error NotAllowed
    end
  end

end
