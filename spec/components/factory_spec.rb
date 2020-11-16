require './components/factory'

RSpec.describe Factory do

  let(:factory) { Factory.new filename: 'spec/fixtures/factory_config.json' }

  let(:neo) { factory.neo }
  let(:px) { factory.px }
  let(:osc) { factory.osc }
  let(:settings) { factory.assets.settings }

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

    expect{ osc }.to output(anything).to_stderr   # Suppressing annoying warning
    expect(osc).to be_a DirectOscServer
    expect(osc.port).to eq 4224
    expect(osc.address).to eq 'no_fixed_abode'

    expect(px.neo_pixel).to eq neo

    expect(settings.max_oversample).to eq 9
  end

  it 'loads asset locations' do
    px.story_mode
    expect(px.filename('tale')).to eq 'a/tall/tale.json'
    px.scene_mode
    expect(px.filename('big_mess')).to eq 'making_a/big_mess.json'
    px.cue_mode
    expect(px.filename('where_due')).to eq 'credits/where_due.json'
    px.layer_mode
    expect(px.filename('orgasms')).to eq 'multiple/orgasms.json'
  end

  it 'overrides display adapter' do
    expect(neo_override).to be_a(HttpNeoPixel)
    expect(neo_override.host).to eq 'with.the.most'
    expect(neo_override.port).to eq 4567
    expect(neo_override.path).to eq 'winding'
  end

end
