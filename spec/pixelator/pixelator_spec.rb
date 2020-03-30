require_relative '../../app/neo_pixel/neo_pixel'
require_relative '../../app/pixelator/pixelator'
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
    expect(pixelator[:base].canvas).to eq px
    expect(pixelator.base.canvas).to eq px
    expect(pixelator.base.color_array).to eq [black]*10
  end

  it 'can define a new layer' do
    pixelator.layer :the_lot
    expect(pixelator[:the_lot].canvas).to eq px
  end

  it 'can define a layer by range' do
    pixelator.layer mid_four: (4..7)
    expect(pixelator[:mid_four].canvas)
        .to eq [4, 5, 6, 7]
  end

  it 'can define a layer by array' do
    pixelator.layer those_three: [1, 6, 9]
    expect(pixelator[:those_three].canvas)
        .to eq [1, 6, 9]
  end

  it 'can define a layer by proc' do
    pixelator.layer evens: proc { |p| p % 2 == 0 }
    expect(pixelator[:evens].canvas)
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
    expect(pixelator[:sum].canvas).to eq px
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
      pixelator.start 0.02
      expect(pixelator.started).to eq true
      sleep 0.03
      pixelator.stop
      expect(pixelator.started).to eq false
      sleep 0.03
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
      pixelator[:a].fill red, 0.8
      pixelator[:b].fill white
      pixelator.render
    end

    let(:black_100) { ColorA.new black }
    let(:white_100) { ColorA.new white }
    let(:red_80) { ColorA.new red, 0.8 }
    let(:faded_red) { Color.new 204, 0, 0 }
    let(:faded_dk_red) { Color.new 102, 0, 0 }

    let(:saved_scene) do
      {layers: [
          {key: :base,
           canvas: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
           background: black,
           opacity: 1.0,
           pattern: [black_100, black_100, black_100, black_100, black_100,
                     black_100, black_100, black_100, black_100, black_100]
          },
          {key: :a,
           canvas: [0, 5, 6],
           background: nil,
           opacity: 0.5,
           pattern: [red_80, red_80, red_80],
           layer_scroller: {
               period: 1.0,
               over_sample: 8
           }
          },
          {key: :b,
           canvas: [2, 4, 7],
           background: nil,
           opacity: 1.0,
           pattern: [white_100, white_100, white_100],
           pattern_scroller: {
               period: -2.0,
               over_sample: 1
           }
          }
      ]}.to_json
    end

    it '.clears' do
      expect(neo_pixel.contents)
          .to eq [faded_red, black, white, black, white,
                  faded_red, faded_red, white, black, black]
      expect(pixelator.layers.size).to eq 3

      pixelator.clear

      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
      expect(pixelator.layers.size).to eq 1
    end

    it '.saves' do
      pixelator[:a].opacity = 0.5
      pixelator[:a].layer_scroller.start 1
      pixelator[:a].layer_scroller.over_sample = 8
      pixelator[:b].pattern_scroller.start -2

      expect(File).to receive(:write).with('scenes/pxfile.json', saved_scene)

      pixelator.save_scene 'pxfile.json'
    end

    it '.loads' do
      allow(File).to receive(:read).with('scenes/pxfile.json')
          .and_return(File.read('./spec/fixtures/pxfile.json'))

      pixelator.clear
      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
      expect(pixelator.layers.size).to eq 1

      pixelator.load_scene('pxfile.json')

      expect(neo_pixel.contents)
          .to eq [faded_dk_red, black, white, black, white,
                  faded_dk_red, faded_dk_red, white, black, black]
      expect(pixelator.layers.size).to eq 3
      expect(pixelator[:a].opacity).to eq 0.5
      expect(pixelator[:a].layer_scroller.period).to eq 1
      expect(pixelator[:a].layer_scroller.over_sample).to eq 4
      expect(pixelator[:b].opacity).to eq(1.0)
      expect(pixelator[:b].pattern_scroller.period).to eq -2
      expect(pixelator[:b].pattern_scroller.over_sample).to eq 1
    end

  end

  context '#hide and #show' do

    let(:scene) { pixelator.scene }
    let!(:layer_1) { scene.layer :a, background: blue }
    let!(:layer_2) { scene.layer({b: [2, 5, 7]}, background: red) }

    it 'initializes with all layers visible' do
      pixelator.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo_pixel.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

    it 'hides a single layer' do
      layer_1.hide
      pixelator.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq true
      expect(neo_pixel.contents)
          .to eq [black, black, red, black, black,
                  red, black, red, black, black]
    end

    it 'hides all layers' do
      scene.hide_all
      pixelator.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
    end

    it 'shows a single layer' do
      scene.hide_all
      pixelator.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      layer_1.show
      pixelator.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq false
      expect(neo_pixel.contents)
          .to eq [blue, blue, blue, blue, blue,
                  blue, blue, blue, blue, blue]
    end

    it 'shows all layers' do
      scene.hide_all
      pixelator.render
      expect(neo_pixel.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      scene.show_all
      pixelator.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo_pixel.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

  end

end
