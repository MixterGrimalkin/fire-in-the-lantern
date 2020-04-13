require_relative '../../app/main/fire_in_the_lantern'

RSpec.describe Factory do

  subject(:factory) { Factory.new 'spec/fixtures/factory_config.json' }

  let(:neo) { factory.neo }
  let(:px) { factory.px }
  let(:scn) { factory.scn }

  it 'creates objects' do
    expect(neo).to be_a OscNeoPixel
    expect(neo.pixel_count).to eq 99
    expect(neo.mode).to eq :grb
    expect(neo.address).to eq 'your_house'

    expect(px).to be_a Pixelator
    expect(px.render_period).to eq 4

    expect(scn).to be_a Scene
    expect(scn.layers.size).to eq 1

    expect(px.neo_pixel).to eq neo
    expect(px.scene).to eq scn
  end

end
