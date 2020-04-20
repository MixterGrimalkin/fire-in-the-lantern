require_relative '../../fitl/neo_pixel/neo_pixel'
require_relative '../../fitl/pixelator/pixelator'

require 'json'

RSpec.describe Pixelator do

  let(:neo) { NeoPixel.new pixel_count: 10 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:scene) { px.scene }

  let(:all_pixels) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:full_white) { Color.new 255, 255, 255, 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }

  let(:dk_red) { Color.new 127, 0, 0 }
  let(:orange) { Color.new 200, 180, 0 }
  let(:dim_orange) { Color.new 100, 90, 0 }

  it 'initializes pixels' do
    expect(px.pixel_count).to eq 10
  end

  it 'renders to NeoPixel' do
    expect(px.neo_pixel).to receive(:show).once
    px[0] = red
    px[1] = blue
    px[2] = black
    px[3] = blue
    px[4] = red
    px[5] = orange
    px[6] = orange * 0.5
    px[7] = black
    px[8] = blue
    px[9] = red
    px.render
    expect(neo.contents)
        .to eq [red, blue, black, blue, red, orange, dim_orange, black, blue, red]
  end

  context '#start and #stop' do
    it 'starts and stops the rendering thread' do
      expect_any_instance_of(NeoPixel).to receive(:show).exactly(3).times
      expect(px.started).to eq false
      px.start 0.1
      expect(px.started).to eq true
      sleep 0.15
      px.stop
      expect(px.started).to eq false
      sleep 0.15
    end
    it 'raises error if already started' do
      px.start
      expect { px.start }.to raise_error NotAllowed
    end
    it 'raises error if already stopped' do
      expect { px.stop }.to raise_error NotAllowed
    end
  end

  it '#all_on and #all_off stop rendering thread' do
    px.all_on
    expect(neo.contents).to eq [full_white] * 10
    px.all_off
    expect(neo.contents).to eq [black] * 10

    px.start 0.01
    sleep 0.01
    expect(px.started).to eq true
    expect(neo.contents).to eq [black] * 10

    px.all_on
    expect(px.started).to eq false
    expect(neo.contents).to eq [full_white] * 10

    px.start 0.01
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

  context 'given a scene' do

    before do
      px.layer :a, canvas: [0, 5, 6]
      px.layer :b, canvas: [2, 4, 7]
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
           },
           modifiers: {
               bouncers: [true, true, true],
               initial_alphas: [1.0, 1.0, 1.0],
               target_alphas: [0.0, 0.0, 0.0],
               target_times: [2.0, 2.0, 2.0]
           }
          }
      ]}.to_json
    end

    it '#clear' do
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

    it '#save_scene' do
      px[:a].opacity = 0.5
      px[:a].layer_scroller.start 1
      px[:a].layer_scroller.over_sample = 8
      px[:b].pattern_scroller.start -2
      px[:b].hide
      px[:b].fade_out 2, bounce: true

      expect(File).to receive(:write)
                          .with('scenes/my_scene.json', saved_scene)

      px.save_scene 'my_scene'
    end

    it '#load_scene' do
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
      expect(px[:a].modifiers.active?).to eq false
      expect(px[:a].layer_scroller.period).to eq 1
      expect(px[:a].layer_scroller.over_sample).to eq 4

      expect(px[:b].opacity).to eq(1.0)
      expect(px[:b].visible).to eq true
      expect(px[:b].modifiers.active?).to eq false
      expect(px[:b].pattern_scroller.period).to eq -2
      expect(px[:b].pattern_scroller.over_sample).to eq 1

      expect(px[:c].visible).to eq false
      expect(px[:c].modifiers.active?).to eq true
      expect(px[:c].modifiers.pixel_config(0))
          .to include(
                  bouncer: true,
                  initial_alpha: 0.0,
                  current_alpha: 0.0,
                  target_alpha: 1.0,
                  target_time: 0.5
              )
    end

  end

  context 'cross-fading' do
    let(:current_scene) do
      scene = px.scene
      scene.layer :a, background: red
      scene
    end
    let(:new_scene) do
      scene = Scene.new(px.pixel_count)
      scene.layer :a, background: blue
      scene
    end

    it 'switches scene' do
      expect(px.scene).to eq current_scene
      px.set_scene new_scene
      expect(px.scene).to eq new_scene
    end

    it 'fades in a scene' do
      expect(px).to receive(:fade_time_elapsed).and_return(0, 0.5, 1, 2)

      expect(px.scene).to eq current_scene
      px.set_scene new_scene, crossfade: 2
      expect(px.scene).to eq current_scene

      px.render
      expect(neo.contents).to eq [red] * 10

      px.render
      expect(neo.contents).to eq [blue.blend_over(red, 0.25)] * 10

      px.render
      expect(neo.contents).to eq [blue.blend_over(red, 0.5)] * 10

      px.render
      expect(neo.contents).to eq [blue] * 10
      expect(px.scene).to eq new_scene

      px.render
      expect(neo.contents).to eq [blue] * 10
    end
  end
end
