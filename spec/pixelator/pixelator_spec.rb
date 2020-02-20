require_relative '../../neo_pixel/neo_pixel'
require_relative '../../pixelator/pixelator'
require 'byebug'

RSpec.describe Pixelator do

  subject(:pixelator) { Pixelator.new NeoPixel.new(10) }

  let(:neo_pixel) { pixelator.neo_pixel }
  let(:px) { pixelator.pixels }

  let(:black) { Color.new }
  let(:red) { Color.new 255,0,0 }
  let(:blue) { Color.new 0,0,255 }
  let(:orange) { Color.new 200,180,0 }
  let(:dim_orange) { Color.new 100,90,0 }

  it 'creates Pixels' do
    expect(pixelator.pixel_count).to eq 10
    expect(px.size).to eq 10
  end
  
  it 'defines All Group' do
    expect(pixelator[:all].pixels).to eq px
  end

  it 'defines a Group by range' do
    pixelator.group mid_four: (4..7)
    expect(pixelator[:mid_four].pixels)
        .to eq [px[4], px[5], px[6], px[7]]
  end

  it 'defines a Group by array' do
    pixelator.group those_three: [1, 6, 9]
    expect(pixelator[:those_three].pixels)
        .to eq [px[1], px[6], px[9]]
  end

  it 'defines a Group by proc' do
    pixelator.group evens: proc { |p| p.number % 2 == 0 }
    expect(pixelator[:evens].pixels)
        .to eq [px[0], px[2], px[4], px[6], px[8]]
  end

  it 'combines groups' do
    pixelator.group left: (0..4)
    pixelator.group right: (5..9)
    pixelator[:sum] = pixelator[:left] + pixelator[:right]
    expect(pixelator[:sum].pixels).to eq px
  end

  it 'subtracts groups' do
    pixelator.group left: (0..4)
    pixelator.group right: (5..9)
    pixelator[:diff] = pixelator[:all] - pixelator[:right]
    expect(pixelator[:diff]).to eq pixelator[:left]
  end

  it 'renders to NeoPixel' do
    expect(neo_pixel).to receive(:show).once
    pixelator[0].set red
    pixelator[1].set blue
    pixelator[2].set black
    pixelator[3].set blue
    pixelator[4].set red
    pixelator[5].set orange
    pixelator[6].set orange, 0.5
    pixelator[7].set black
    pixelator[8].set blue
    pixelator[9].set red
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
