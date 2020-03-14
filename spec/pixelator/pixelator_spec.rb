require_relative '../../neo_pixel/neo_pixel'
require_relative '../../pixelator/pixelator'
require 'byebug'
require 'json'

RSpec.describe Pixelator do

  subject(:pixelator) { Pixelator.new NeoPixel.new(10) }

  let(:neo_pixel) { pixelator.neo_pixel }

  let(:px) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:dk_red) { Color.new 127, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }
  let(:orange) { Color.new 200, 180, 0 }
  let(:dim_orange) { Color.new 100, 90, 0 }

  it 'initializes pixels' do
    expect(pixelator.pixel_count).to eq 10
  end

  it 'initializes the base layer' do
    expect(pixelator[:base].pixels).to eq px
    expect(pixelator.base.pixels).to eq px
    expect(pixelator.base.contents).to eq [black]*10
  end

  it 'can define a new layer' do
    pixelator.layer :the_lot
    expect(pixelator[:the_lot].pixels).to eq px
  end

  it 'can define a layer by range' do
    pixelator.layer mid_four: (4..7)
    expect(pixelator[:mid_four].pixels)
        .to eq [4, 5, 6, 7]
  end

  it 'can define a layer by array' do
    pixelator.layer those_three: [1, 6, 9]
    expect(pixelator[:those_three].pixels)
        .to eq [1, 6, 9]
  end

  it 'can define a layer by proc' do
    pixelator.layer evens: proc { |p| p % 2 == 0 }
    expect(pixelator[:evens].pixels)
        .to eq [0, 2, 4, 6, 8]
  end

  it 'defines a method for new layers' do
    pixelator.layer odds: proc { |p| p % 2 != 0 }
    expect(pixelator.scene.odds).to eq pixelator[:odds]
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
      expect_any_instance_of(NeoPixel).to receive(:show).exactly(3).times
      expect(pixelator.started).to eq false
      pixelator.start 0.4
      expect(pixelator.started).to eq true
      sleep 0.6
      pixelator.stop
      expect(pixelator.started).to eq false
      sleep 0.6
    end
    it 'raises error if already started' do
      pixelator.start
      expect { pixelator.start }.to raise_error NotAllowed
    end
    it 'raises error if already stopped' do
      expect { pixelator.stop }.to raise_error NotAllowed
    end
  end

  it '.all_on and .all_off stop rendering thread' do
    pixelator.all_on
    expect(neo_pixel.contents).to eq [white] * 10
    pixelator.all_off
    expect(neo_pixel.contents).to eq [black] * 10

    pixelator.start
    sleep 0.01
    expect(pixelator.started).to eq true
    expect(neo_pixel.contents).to eq [black] * 10

    pixelator.all_on
    expect(pixelator.started).to eq false
    expect(neo_pixel.contents).to eq [white] * 10

    pixelator.start
    sleep 0.01
    expect(pixelator.started).to eq true
    expect(neo_pixel.contents).to eq [black] * 10

    pixelator.base.fill red
    sleep 0.01
    expect(neo_pixel.contents).to eq [red] * 10

    pixelator.all_off
    expect(pixelator.started).to eq false
    expect(neo_pixel.contents).to eq [black] * 10
  end

  context 'when there is a pattern running' do

    before do
      pixelator.layer a: [0, 5, 6]
      pixelator.layer b: [2, 4, 7]
      pixelator[:a].fill red
      pixelator[:b].fill white
      pixelator.render
    end

    let(:saved_scene) do
      {layers: [
          {key: :base,
           pixels: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
           contents: [black, black, black, black, black,
                      black, black, black, black, black],
           opacity: 1.0,
           pixel_opacity: [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
          },
          {key: :a,
           pixels: [0, 5, 6],
           contents: [red, red, red],
           opacity: 0.5,
           pixel_opacity: [1.0, 1.0, 1.0],
           scroll: 1
          },
          {key: :b,
           pixels: [2, 4, 7],
           contents: [white, white, white],
           opacity: 1.0,
           pixel_opacity: [1.0, 1.0, 1.0],
           scroll: -2
          }
      ]}.to_json
    end

    it '.clears' do
      expect(neo_pixel.contents)
          .to eq [red, black, white, black, white, red, red, white, black, black]
      expect(pixelator.layers.size).to eq 3

      pixelator.clear

      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black, black, black, black, black, black]
      expect(pixelator.layers.size).to eq 1
    end


    it '.saves' do
      pixelator[:a].layer_opacity = 0.5
      pixelator[:a].start_scroll 1
      pixelator[:b].start_scroll -2

      expect(File).to receive(:write).with('pxfile.json', saved_scene)

      pixelator.save_scene 'pxfile.json'
    end

    it '.loads' do
      allow(File).to receive(:read).with('pxfile.json')
          .and_return(File.read('./spec/fixtures/pxfile.json'))

      pixelator.clear
      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black, black, black, black, black, black]
      expect(pixelator.layers.size).to eq 1

      pixelator.load_scene('pxfile.json')

      expect(neo_pixel.contents)
          .to eq [dk_red, black, white, black, white, dk_red, dk_red, white, black, black]
      expect(pixelator.layers.size).to eq 3
      expect(pixelator[:a].layer_opacity).to eq 0.5
      expect(pixelator[:a].scroll_period).to eq 1
      expect(pixelator[:b].layer_opacity).to eq(1.0)
      expect(pixelator[:b].scroll_period).to eq -2
    end

  end

end
