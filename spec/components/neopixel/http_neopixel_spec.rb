require './components/neopixel/http_neopixel'
require 'net/http'

include Fitl
include Colours

RSpec.describe Fitl::HttpNeopixel do

  subject(:neo) do
    described_class.new(
        pixel_count: 2,
        mode: :grb,
        host: '192.168.1.1',
        port: '8080',
        path: 'why/thing'
    )
  end

  it 'updates via http' do
    expect(Net::HTTP)
        .to receive(:post).with(
            URI('http://192.168.1.1:8080/why/thing'),
            'data=[0,255,0,0,255,0]'
        )

    neo.on RED
  end
end