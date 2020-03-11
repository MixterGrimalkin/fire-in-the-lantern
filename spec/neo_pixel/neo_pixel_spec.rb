require_relative '../../neo_pixel/neo_pixel'

RSpec.describe NeoPixel do

  subject(:neo_pixel) { NeoPixel.new 4, mode: mode }

  let(:mode) { :rgb }

  let(:black) { Color.new 0, 0, 0 }
  let(:yellow) { Color.new 200, 255, 0 }
  let(:white) { Color.new 255, 255, 255, 255 }
  let(:cyan) { Color.new 0, 200, 255 }

  context '.initialize' do
    it 'initializes in OFF state without rendering' do
      expect_any_instance_of(NeoPixel).not_to receive(:show)
      expect(neo_pixel.contents).to eq [black, black, black, black]
    end
  end

  context '.set' do
    it 'sets single pixel colour' do
      neo_pixel.set 2, yellow
      expect(neo_pixel.contents).to eq [black, black, yellow, black]
    end
    it 'raises error if pixel out of range' do
      expect { neo_pixel.set -3, yellow }.to raise_error PixelOutOfRangeError
      expect { neo_pixel.set 7, yellow }.to raise_error PixelOutOfRangeError
    end
  end

  context '.set_range' do
    it 'sets pixel range colour' do
      neo_pixel.set_range 1, 2, yellow
      expect(neo_pixel.contents).to eq [black, yellow, yellow, black]
    end
    it 'raises error if pixel range too large' do
      expect { neo_pixel.set_range 1, 9, yellow }.to raise_error PixelOutOfRangeError
      expect { neo_pixel.set_range -4, 2, yellow }.to raise_error PixelOutOfRangeError
    end
  end

  context '.all_on and .all_off' do
    it 'renders all ON and OFF' do
      expect_any_instance_of(NeoPixel).to receive(:show).twice
      neo_pixel.all_on
      expect(neo_pixel.contents).to eq [white, white, white, white]
      neo_pixel.all_off
      expect(neo_pixel.contents).to eq [black, black, black, black]
    end
  end

  context '.fill' do
    it 'fills contents but does not render' do
      expect(neo_pixel).not_to receive(:show)
      neo_pixel.fill yellow
      expect(neo_pixel.contents).to eq [yellow, yellow, yellow, yellow]
    end
  end

  context 'when unknown output mode' do
    let(:mode) { :magic }
    it 'raises an error' do
      expect { neo_pixel.render }.to raise_error BadOutputMode
    end
  end

  context 'output modes' do
    before do
      neo_pixel.set 0, white
      neo_pixel.set 1, cyan
      neo_pixel.set 3, yellow
      expect(neo_pixel).to receive(:show).with(buffer)
    end
    context 'RGB mode' do
      let(:mode) { :rgb }
      let(:buffer) do
        [255,255,255, 0,200,255, 0,0,0, 200,255,0]
      end
      it 'renders RGB' do
        expect(neo_pixel.rgb_count).to eq 4
        neo_pixel.render
      end
    end
    context 'GRB mode' do
      let(:mode) { :grb }
      let(:buffer) do
        [255,255,255, 200,0,255, 0,0,0, 255,200,0]
      end
      it 'renders GRB' do
        expect(neo_pixel.rgb_count).to eq 4
        neo_pixel.render
      end
    end
    context 'RGBW mode' do
      let(:mode) { :rgbw }
      let(:buffer) do
        [255,255,255, 255,0,200, 255,0,0, 0,0,0, 200,255,0, 0,0,0]
      end
      it 'renders RGBW' do
        expect(neo_pixel.rgb_count).to eq 6
        neo_pixel.render
      end
    end
  end

end
