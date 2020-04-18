require_relative '../../app/main/fire_in_the_lantern'

RSpec.describe Factory do

  subject(:factory) { Factory.new filename: 'spec/fixtures/factory_config.json' }

  let(:neo) { factory.neo }
  let(:px) { factory.px }
  let(:scn) { factory.scn }
  let(:osc) { factory.osc }

  it 'creates objects' do
    expect(neo).to be_a OscNeoPixel
    expect(neo.pixel_count).to eq 99
    expect(neo.mode).to eq :grb
    expect(neo.address).to eq 'your_house'

    expect(px).to be_a Pixelator
    expect(px.render_period).to eq 0.5

    expect(scn).to be_a Scene
    expect(scn.layers.size).to eq 1

    expect{ osc }.to output(anything).to_stderr
    expect(osc).to be_a OscServer
    expect(osc.server_port).to eq 4224
    expect(osc.osc_address).to eq 'no_fixed_abode'

    expect(px.neo_pixel).to eq neo
    expect(px.scene).to eq scn
  end

end
