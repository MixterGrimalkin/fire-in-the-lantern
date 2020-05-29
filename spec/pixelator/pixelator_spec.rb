require_relative '../../fitl/neo_pixel/neo_pixel'
require_relative '../../fitl/pixelator/pixelator'
require_relative '../../fitl/color/tools'

include Colors

RSpec.describe Pixelator do

  subject(:px) { Pixelator.new neo_pixel: neo }

  let(:neo) { NeoPixel.new pixel_count: 10 }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:full_white) { Color.new 255, 255, 255, 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }

  let(:dk_red) { Color.new 127, 0, 0 }
  let(:orange) { Color.new 200, 180, 0 }
  let(:dim_orange) { Color.new 100, 90, 0 }

  it '.initialize' do
    expect(px.pixel_count).to eq 10
    expect(px.mode).to eq :layer
  end

  context 'Layer mode' do
    before do
      px.layer_mode
    end

    it 'creates layer' do
      expect(px.mode).to eq :layer
      expect(px.get).to be_a Layer
    end

    it 'builds layer' do
      px.build({size: 20,
                visible: true,
                opacity: 0.5,
                fill: red})
      layer = px.get
      expect(layer).to be_a Layer
      expect(layer.size).to eq 20
      expect(layer.visible).to eq true
      expect(layer.opacity).to eq 0.5
      expect(px.buffer).to eq [red / 2] * 10
    end

    it 'loads layer' do
      expect(File)
          .to receive(:read).with('layers/a_layer.json')
                  .and_return(File.read('./spec/fixtures/a_layer.json'))

      px.load_file 'a_layer'
      layer = px.get
      expect(layer.name).to eq 'My Lovely Layer'
      expect(layer.size).to eq 2
      expect(layer.visible).to eq true
      expect(layer.opacity).to eq 0.5
      expect(layer.scroller.period).to eq -0.8
      expect(layer.scroller.oversample).to eq 9
      expect(layer.scroller.active).to eq true
      expect(layer.contents).to eq [ColorA.create(100, 200, 0, 50, 1.0), ColorA.create(100, 0, 50, 0, 0.5)]
    end

    it 'saves layer' do
      expect(File)
          .to receive(:write).with('layers/a_layer.json', File.read('./spec/fixtures/a_layer.json'))

      px.build({size: 2,
                name: 'My Lovely Layer',
                opacity: 0.5,
                scroller: Scroller.new(size: 2, period: -0.8, oversample: 9, active: false)
               })
      px.get[0] = Color.new(100, 200, 0, 50)
      px.get.set(1, Color.new(100, 0, 50), 0.5)
      px.get.scroll

      px.save_file 'a_layer'
    end
  end

  context 'Cue mode' do
    before do
      px.cue_mode
    end

    it 'creates cue' do
      expect(px.mode).to eq :cue
      expect(px.get).to be_a Cue
    end
  end

  context 'Scene mode' do
    before do
      px.scene_mode
    end

    it 'creates scene' do
      expect(px.mode).to eq :scene
      expect(px.get).to be_a Scene
    end
  end

  context 'Story mode' do
    before do
      px.story_mode
    end

    it 'creates story' do
      expect(px.mode).to eq :story
      expect(px.get).to be_a Story
    end
  end

  it 'renders to NeoPixel' do
    expect(px.neo_pixel).to receive(:show).once
    px.get.draw([red, blue, black, blue, red,
                orange, orange / 2, black, blue, red])
    px.render
    expect(neo.contents)
        .to eq [red, blue, black, blue, red, orange, dim_orange, black, blue, red]
  end

  context '.start and .stop' do
    it 'starts and stops the rendering thread' do
      expect_any_instance_of(NeoPixel).to receive(:show).exactly(3).times
      expect_any_instance_of(Layer).to receive(:update).twice
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
      expect { px.start }.to raise_error AlreadyStarted
    end
    it 'does not raise error if already stopped' do
      expect { px.stop }.to_not raise_error
    end
  end

end
