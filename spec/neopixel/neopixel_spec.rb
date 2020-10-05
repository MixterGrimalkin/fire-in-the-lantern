require './neopixel/neopixel'

include Fitl
include Colours

RSpec.describe Fitl::Neopixel do

  subject(:neo) { described_class.new pixel_count: 4, mode: mode }

  let(:mode) { :rgb }

  let(:black) { Colour.new }
  let(:yellow) { Colour.new 200, 255, 0 }
  let(:white) { Colour.new 255, 255, 255, 255 }
  let(:cyan) { Colour.new 0, 200, 255 }

  let(:transparent_red) { Colour.new 200, 0, 0, alpha: 0.5 }
  let(:faded_red) { Colour.new 100, 0, 0, alpha: 1.0 }

  let(:empty) { [black, black, black, black] }
  let(:pattern) { [white, cyan, black, yellow] }

  it '.initialize' do
    expect_any_instance_of(Neopixel).not_to receive(:show)
    expect(neo.contents).to eq empty
  end

  it '.[]' do
    expect(neo[2]).to eq black
    neo[2] = yellow
    expect(neo[2]).to eq yellow
    neo[0] = transparent_red
    expect(neo.contents).to eq [faded_red, black, yellow, black]
  end

  it '.[] out of bounds' do
    expect { neo[-3] = yellow }.to raise_error Neopixel::BadPixelNumber
    expect { neo[7] }.to raise_error Neopixel::BadPixelNumber
  end

  it '.write' do
    expect_any_instance_of(Neopixel).not_to receive(:show)
    expect(neo.write pattern).to eq neo
    expect(neo.contents).to eq pattern
  end

  it '.write wrong size' do
    expect { neo.write [black, white] }.to raise_error Neopixel::BadPixelNumber
    expect { neo.write [black, white, white, cyan, black] }.to raise_error Neopixel::BadPixelNumber
  end

  it '.on and .off' do
    expect_any_instance_of(Neopixel).to receive(:show).exactly(4).times
    neo.on
    expect(neo.contents).to eq [white, white, white, white]
    neo.on cyan
    expect(neo.contents).to eq [cyan, cyan, cyan, cyan]
    neo.on transparent_red
    expect(neo.contents).to eq [faded_red, faded_red, faded_red, faded_red]
    neo.off
    expect(neo.contents).to eq empty
  end

  context 'invalid output mode' do
    let(:mode) { :magic }
    it 'raises an error' do
      expect { neo.render }.to raise_error Neopixel::BadOutputMode
    end
  end

  context 'valid output mode' do
    before do
      neo[0] = white
      neo[1] = cyan.override(alpha: 0.5)
      neo[3] = yellow
      expect(neo).to receive(:show).with(buffer)
    end
    context 'RGB mode' do
      let(:mode) { :rgb }
      let(:buffer) do
        [255, 255, 255, 0, 100, 127, 0, 0, 0, 200, 255, 0]
      end
      it 'renders RGB' do
        expect(neo.rgb_count).to eq 4
        neo.render
      end
    end
    context 'GRB mode' do
      let(:mode) { :grb }
      let(:buffer) do
        [255, 255, 255, 100, 0, 127, 0, 0, 0, 255, 200, 0]
      end
      it 'renders GRB' do
        expect(neo.rgb_count).to eq 4
        neo.render
      end
    end
    context 'RGBW mode' do
      let(:mode) { :rgbw }
      let(:buffer) do
        [255, 255, 255, 255, 0, 100, 127, 0, 0, 0, 0, 0, 200, 255, 0, 0, 0, 0]
      end
      it 'renders RGBW' do
        expect(neo.rgb_count).to eq 6
        neo.render
      end
    end
  end
end
