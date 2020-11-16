require './components/neopixel/ws_neopixel'
require 'ws2812'

include Fitl
include Colours

RSpec.describe Fitl::WsNeopixel do

  subject(:neo) do
    described_class.new(
        pixel_count: 2,
        mode: :rgbw,
        pin: 18,
        brightness: 128
    )
  end

  it 'writes to WS281x' do
    expect(Ws2812::Basic)
        .to receive(:new)
                .with(3, 18, 128, {})
                .and_return(ws_dbl = double(Ws2812::Basic))

    expect(ws_dbl).to receive(:open)
    allow(ws_dbl).to receive(:[]=)

    neo

    expect(Ws2812::Color).to receive(:new).with(255, 0, 0).ordered.and_call_original
    expect(Ws2812::Color).to receive(:new).with(0, 255, 0).ordered.and_call_original
    expect(Ws2812::Color).to receive(:new).with(0, 0, 0).ordered.and_call_original

    expect(ws_dbl).to receive(:show)

    neo.on RED
  end
end