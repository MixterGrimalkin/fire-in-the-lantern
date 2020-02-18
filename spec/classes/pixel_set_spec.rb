require_relative '../../classes/neo_pixel'
require_relative '../../classes/pixel_set'
require 'byebug'

RSpec.describe PixelSet do

  subject(:pixel_set) { PixelSet.new NeoPixel.new(10) }

  let(:neo_pixel) { pixel_set.neo_pixel }
  let(:px) { pixel_set.pixels }

  let(:black) { Color.new }
  let(:red) { Color.new 255,0,0 }
  let(:blue) { Color.new 0,0,255 }
  let(:orange) { Color.new 200,180,0 }
  let(:dim_orange) { Color.new 100,90,0 }

  it 'creates Pixels' do
    expect(pixel_set.pixel_count).to eq 10
    expect(px.size).to eq 10
  end

  it 'defines a Group by range' do
    pixel_set[:mid_four] = (4..7)
    expect(pixel_set[:mid_four]).to eq [px[4], px[5], px[6], px[7]]
  end

  it 'defines a Group by array' do
    pixel_set[:those_three] = [1, 6, 9]
    expect(pixel_set[:those_three]).to eq [px[1], px[6], px[9]]
  end

  it 'defines a Group by proc' do
    pixel_set[:evens] = proc { |p| p.number % 2 == 0 }
    expect(pixel_set[:evens]).to eq [px[0], px[2], px[4], px[6], px[8]]
  end

  it 'renders to NeoPixel' do
    expect(neo_pixel).to receive(:show).once
    pixel_set[0].set red
    pixel_set[1].set blue
    pixel_set[2].set black
    pixel_set[3].set blue
    pixel_set[4].set red
    pixel_set[5].set orange
    pixel_set[6].set orange, 0.5
    pixel_set[7].set black
    pixel_set[8].set blue
    pixel_set[9].set red
    pixel_set.render
    expect(neo_pixel.contents)
        .to eq [red, blue, black, blue, red, orange, dim_orange, black, blue, red]
  end

end
