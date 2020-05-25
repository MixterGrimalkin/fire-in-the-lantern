require_relative '../../fitl/neo_pixel/neo_pixel'

RSpec.describe NeoPixel do

  subject(:neo_pixel) { NeoPixel.new pixel_count: 4, mode: mode }

  let(:mode) { :rgb }

  let(:black) { Color.new 0, 0, 0 }
  let(:yellow) { Color.new 200, 255, 0 }
  let(:white) { Color.new 255, 255, 255, 255 }
  let(:cyan) { Color.new 0, 200, 255 }

  let(:empty) { [black, black, black, black] }
  let(:contents) { [white, cyan, black, yellow] }

  it '.initialize' do
    expect_any_instance_of(NeoPixel).not_to receive(:show)
    expect(neo_pixel.contents).to eq empty
  end

  it 'set' do
    expect(neo_pixel[2]).to eq black
    neo_pixel[2] = yellow
    expect(neo_pixel[2]).to eq yellow
    expect(neo_pixel.contents).to eq [black, black, yellow, black]
  end

  it 'set out of range' do
    expect { neo_pixel[-3] = yellow }.to raise_error BadPixelNumber
    expect { neo_pixel[7] = yellow }.to raise_error BadPixelNumber
  end

  it '.write' do
    expect_any_instance_of(NeoPixel).not_to receive(:show)
    expect(neo_pixel.write pattern).to eq neo_pixel
    expect(neo_pixel.contents).to eq pattern
  end

  it '.write wrong size' do
    expect { neo_pixel.write [black, white] }.to raise_error BadPixelNumber
    expect { neo_pixel.write [black, white, white, cyan, black] }.to raise_error BadPixelNumber
  end

  it '.on and .off' do
    expect_any_instance_of(NeoPixel).to receive(:show).exactly(3).times
    neo_pixel.on
    expect(neo_pixel.contents).to eq [white, white, white, white]
    neo_pixel.on cyan
    expect(neo_pixel.contents).to eq [cyan, cyan, cyan, cyan]
    neo_pixel.off
    expect(neo_pixel.contents).to eq empty
  end

  context 'invalid output mode' do
    let(:mode) { :magic }
    it 'raises an error' do
      expect { neo_pixel.render }.to raise_error BadOutputMode
    end
  end

  context 'valid output modes' do
    before do
      neo_pixel[0] = white
      neo_pixel[1] = cyan
      neo_pixel[3] = yellow
      expect(neo_pixel).to receive(:show).with(buffer)
    end
    context 'RGB mode' do
      let(:mode) { :rgb }
      let(:buffer) do
        [255, 255, 255, 0, 200, 255, 0, 0, 0, 200, 255, 0]
      end
      it 'renders RGB' do
        expect(neo_pixel.rgb_count).to eq 4
        neo_pixel.render
      end
    end
    context 'GRB mode' do
      let(:mode) { :grb }
      let(:buffer) do
        [255, 255, 255, 200, 0, 255, 0, 0, 0, 255, 200, 0]
      end
      it 'renders GRB' do
        expect(neo_pixel.rgb_count).to eq 4
        neo_pixel.render
      end
    end
    context 'RGBW mode' do
      let(:mode) { :rgbw }
      let(:buffer) do
        [255, 255, 255, 255, 0, 200, 255, 0, 0, 0, 0, 0, 200, 255, 0, 0, 0, 0]
      end
      it 'renders RGBW' do
        expect(neo_pixel.rgb_count).to eq 6
        neo_pixel.render
      end
    end
  end

end
