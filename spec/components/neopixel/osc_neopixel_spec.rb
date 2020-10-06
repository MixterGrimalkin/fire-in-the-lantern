require './components/neopixel/osc_neopixel'
require 'osc-ruby'

include Fitl
include Colours

RSpec.describe Fitl::OscNeopixel do

  subject(:neo) do
    described_class.new(
        pixel_count: 2,
        mode: :rgbw,
        host: '192.168.1.8',
        port: 3333,
        address: 'lol'
    )
  end

  it 'updates via osc' do
    expect(OSC::Client)
        .to receive(:new)
                .with('192.168.1.8', 3333)
                .and_return(client_dbl = double(OSC::Client))

    neo

    expect(OSC::Message)
        .to receive(:new)
                .with('/lol', '255 0 0 0 255 0 0 0 0')
                .and_return(message_dbl = double(OSC::Message))

    expect(client_dbl).to receive(:send).with(message_dbl)

    neo.on RED
  end
end