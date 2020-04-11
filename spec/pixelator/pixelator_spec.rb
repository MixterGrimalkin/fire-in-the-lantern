require_relative '../../app/neo_pixel/neo_pixel'
require_relative '../../app/pixelator/pixelator'

require 'json'

RSpec.describe Pixelator do

  subject(:px) { Pixelator.new neo_pixel: NeoPixel.new(pixel_count: 10) }

  let(:neo) { px.neo_pixel }

  let(:all_pixels) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:dk_red) { Color.new 127, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }
  let(:orange) { Color.new 200, 180, 0 }
  let(:dim_orange) { Color.new 100, 90, 0 }

  it 'initializes pixels' do
    expect(px.pixel_count).to eq 10
  end

  it 'initializes the base layer' do
    expect(px[:base].canvas).to eq all_pixels
    expect(px.base.canvas).to eq all_pixels
    expect(px.base.color_array).to eq [black]*10
  end

  it 'can define a new layer' do
    px.layer :the_lot
    expect(px[:the_lot].canvas).to eq all_pixels
  end

  it 'can define a layer by range' do
    px.layer mid_four: (4..7)
    expect(px[:mid_four].canvas)
        .to eq [4, 5, 6, 7]
  end

  it 'can define a layer by array' do
    px.layer those_three: [1, 6, 9]
    expect(px[:those_three].canvas)
        .to eq [1, 6, 9]
  end

  it 'can define a layer by proc' do
    px.layer evens: proc { |p| p % 2 == 0 }
    expect(px[:evens].canvas)
        .to eq [0, 2, 4, 6, 8]
  end

  it 'defines a method for new layers' do
    px.layer odds: proc { |p| p % 2 != 0 }
    expect(px.scene.odds).to eq px[:odds]
  end

  it 'can combine layers' do
    px.layer left: (0..4)
    px.layer right: (5..9)
    px[:sum] = px[:left] + px[:right]
    expect(px[:sum].canvas).to eq all_pixels
  end

  it 'can subtract layers' do
    px.layer left: (0..4)
    px.layer right: (5..9)
    px[:diff] = px[:base] - px[:right]
    expect(px[:diff]).to eq px[:left]
  end

  it 'renders to NeoPixel' do
    expect(neo).to receive(:show).once
    px[0] = red
    px[1] = blue
    px[2] = black
    px[3] = blue
    px[4] = red
    px[5] = orange
    px[6] = orange.with_brightness 0.5
    px[7] = black
    px[8] = blue
    px[9] = red
    px.render
    expect(neo.contents)
        .to eq [red, blue, black, blue, red, orange, dim_orange, black, blue, red]
  end

  context '.start and .stop' do
    it 'starts and stops the rendering thread' do
      expect_any_instance_of(NeoPixel).to receive(:show).exactly(3).times
      expect(px.started).to eq false
      px.start 0.02
      expect(px.started).to eq true
      sleep 0.03
      px.stop
      expect(px.started).to eq false
      sleep 0.03
    end
    it 'raises error if already started' do
      px.start
      expect { px.start }.to raise_error NotAllowed
    end
    it 'raises error if already stopped' do
      expect { px.stop }.to raise_error NotAllowed
    end
  end

  it '.all_on and .all_off stop rendering thread' do
    px.all_on
    expect(neo.contents).to eq [white] * 10
    px.all_off
    expect(neo.contents).to eq [black] * 10

    px.start
    sleep 0.01
    expect(px.started).to eq true
    expect(neo.contents).to eq [black] * 10

    px.all_on
    expect(px.started).to eq false
    expect(neo.contents).to eq [white] * 10

    px.start
    sleep 0.01
    expect(px.started).to eq true
    expect(neo.contents).to eq [black] * 10

    px.base.fill red
    sleep 0.01
    expect(neo.contents).to eq [red] * 10

    px.all_off
    expect(px.started).to eq false
    expect(neo.contents).to eq [black] * 10
  end

  context 'when there is a pattern running' do

    before do
      px.layer a: [0, 5, 6]
      px.layer b: [2, 4, 7]
      px[:a].fill red, 0.8
      px[:b].fill white
      px.render
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
           visible: true,
           pattern: [black_100, black_100, black_100, black_100, black_100,
                     black_100, black_100, black_100, black_100, black_100]
          },
          {key: :a,
           canvas: [0, 5, 6],
           background: nil,
           opacity: 0.5,
           visible: true,
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
           visible: false,
           pattern: [white_100, white_100, white_100],
           pattern_scroller: {
               period: -2.0,
               over_sample: 1
           }
          }
      ]}.to_json
    end

    it '.clears' do
      expect(neo.contents)
          .to eq [faded_red, black, white, black, white,
                  faded_red, faded_red, white, black, black]
      expect(px.layers.size).to eq 3

      px.clear

      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
      expect(px.layers.size).to eq 1
    end

    it '.saves' do
      px[:a].opacity = 0.5
      px[:a].layer_scroller.start 1
      px[:a].layer_scroller.over_sample = 8
      px[:b].pattern_scroller.start -2
      px[:b].hide

      expect(File).to receive(:write)
                          .with('scenes/my_scene.json', saved_scene)

      px.save_scene 'my_scene'
    end

    it '.loads' do
      allow(File).to receive(:read)
                         .with('scenes/my_scene.json')
                         .and_return(File.read('./spec/fixtures/scene.json'))

      px.clear
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
      expect(px.layers.size).to eq 1

      px.load_scene('my_scene')

      expect(neo.contents)
          .to eq [faded_dk_red, black, white, black, white,
                  faded_dk_red, faded_dk_red, white, black, black]
      expect(px.layers.size).to eq 4
      expect(px[:a].opacity).to eq 0.5
      expect(px[:a].visible).to eq true
      expect(px[:a].layer_scroller.period).to eq 1
      expect(px[:a].layer_scroller.over_sample).to eq 4

      expect(px[:b].opacity).to eq(1.0)
      expect(px[:b].visible).to eq true
      expect(px[:b].pattern_scroller.period).to eq -2
      expect(px[:b].pattern_scroller.over_sample).to eq 1

      expect(px[:c].visible).to eq false
    end

  end

  context '#hide and #show' do

    let(:scene) { px.scene }
    let!(:layer_1) { scene.layer :a, background: blue }
    let!(:layer_2) { scene.layer({b: [2, 5, 7]}, background: red) }

    it 'initializes with all layers visible' do
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

    it 'hides a single layer' do
      layer_1.hide
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [black, black, red, black, black,
                  red, black, red, black, black]
    end

    it 'hides all layers' do
      scene.hide_all
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
    end

    it 'shows a single layer' do
      scene.hide_all
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      layer_1.show
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [blue, blue, blue, blue, blue,
                  blue, blue, blue, blue, blue]
    end

    it 'shows all layers' do
      scene.hide_all
      px.render
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      scene.show_all
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

  end

  context 'Layer re-ordering' do
    let(:scene) { px.scene }

    before do
      scene.layer({layer_1: [1, 5, 9]}, background: red)
      scene.layer(:layer_2, background: blue)
      scene.layer({layer_3: [2, 5, 7]}, background: white)
      px.render
      expect(neo.contents)
          .to eq [blue, blue, white, blue, blue,
                  white, blue, white, blue, blue]
    end

    it '#put_top' do
      expect { scene.put_top(:not_exist) }.to raise_error(LayerNotFound)

      scene.put_top(:layer_1)

      px.render
      expect(neo.contents)
          .to eq [blue, red, white, blue, blue,
                  red, blue, white, blue, red]
    end

    it '#put_bottom' do
      expect { scene.put_bottom(:not_exist) }.to raise_error(LayerNotFound)

      scene.put_bottom(:layer_3)

      px.render
      expect(neo.contents)
          .to eq [blue, blue, blue, blue, blue,
                  blue, blue, blue, blue, blue]
    end
  end
end
