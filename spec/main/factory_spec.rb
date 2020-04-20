require_relative '../../fitl/main/fire_in_the_lantern'

RSpec.describe Factory do

  let(:factory) { Factory.new filename: 'spec/fixtures/factory_config.json' }

  let(:neo) { factory.neo }
  let(:px) { factory.px }
  let(:scn) { factory.scn }
  let(:osc) { factory.osc }
  let(:settings) { factory.settings }

  let(:factory_with_override) do
    Factory.new filename: 'spec/fixtures/factory_config.json', adapter_override: :HttpNeoPixel
  end
  let(:neo_override) { factory_with_override.neo }

  it 'creates objects' do
    expect(neo.pixel_count).to eq 99
    expect(neo.mode).to eq :grb

    expect(neo).to be_a OscNeoPixel
    expect(neo.host).to eq '99.99.99.99'
    expect(neo.port).to eq 1701
    expect(neo.address).to eq 'your_house'

    expect(px).to be_a Pixelator
    expect(px.frame_rate).to eq 2
    expect(px.render_period).to eq 0.5

    expect(scn).to be_a Scene
    expect(scn.layers.size).to eq 1

    expect{ osc }.to output(anything).to_stderr   # Suppressing annoying warning
    expect(osc).to be_a DirectOscServer
    expect(osc.port).to eq 4224
    expect(osc.address).to eq 'no_fixed_abode'

    expect(px.neo_pixel).to eq neo
    expect(px.scene).to eq scn

    expect(px.scenes_dir).to eq 'making'
    expect(px.default_crossfade).to eq 1.9
    expect(settings.monitor_fps).to eq true
    expect(settings.max_over_sample).to eq 9
  end

  it 'overrides display adapter' do
    expect(neo_override).to be_a(HttpNeoPixel)
    expect(neo_override.host).to eq 'with.the.most'
    expect(neo_override.port).to eq 4567
    expect(neo_override.path).to eq 'winding'
  end

end
