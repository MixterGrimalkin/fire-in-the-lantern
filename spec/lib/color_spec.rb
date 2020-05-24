require_relative '../../fitl/lib/color'
require_relative '../../fitl/lib/color_a'

RSpec.describe Color do

  it '.initialize' do
    expect(Color.new).to eq(Color.new(0, 0, 0, 0))
    expect(Color.new(255)).to eq(Color.new(255, 255, 255, 0))
  end

  it 'returns cropped component values' do
    expect(Color.new(300, 0, 0)).to eq Color.new(255, 0, 0)
    expect(Color.new(200, -50, 0)).to eq Color.new(200, 0, 0)
    expect(Color.new(200, 50, 0, 900)).to eq Color.new(200, 50, 0, 255)
  end

  it '.== and .!=' do
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3)).to eq true
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 99)).to eq false
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 99)).to eq true
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 99, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 99, 4)).to eq true
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 99)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 99)).to eq true
  end

  it '.+' do
    expect(Color.new(255, 100, 90, 8) + Color.new(255, 200, 30))
        .to eq Color.new(255, 255, 120, 8)
  end

  it '.-' do
    expect(Color.new(255, 100, 90, 8) - Color.new(255, 20, 30, 20))
        .to eq Color.new(0, 80, 60, 0)
  end

  it '.*' do
    expect(Color.new(100, 50, 20, 10) * 0.5)
        .to eq Color.new(50, 25, 10, 5)
    expect(Color.new(100, 50, 20, 10) * 3)
        .to eq Color.new(255, 150, 60, 30)
  end

  it './' do
    expect(Color.new(100, 50, 20, 10) / 2)
        .to eq Color.new(50, 25, 10, 5)
    expect(Color.new(100, 50, 20, 10) / 20)
        .to eq Color.new(5, 2, 1, 0)
  end

  it '.-@' do
    expect(-Color.new(255, 0, 0))
        .to eq Color.new(0, 255, 255, 255)
    expect(-Color.new(0, 255, 0, 0))
        .to eq Color.new(255, 0, 255, 255)
  end

  let(:full_white) { Color.new(200, 200, 200, 200) }
  let(:red) { Color.new(200, 0, 0, 0) }
  let(:yellow) { Color.new(100, 200, 0) }
  let(:orange) { Color.new 150, 100, 0 }

  it '.blend_over' do
    expect(red.blend_over yellow).to eq red
    expect(red.blend_over yellow, 0).to eq yellow
    expect(red.blend_over yellow, 0.5).to eq orange

    expect(full_white.blend_over red, 0.25).to eq Color.new 200, 50, 50, 50
    expect(red.blend_over full_white, 0.25).to eq Color.new(200, 150, 150, 150)
  end

  it '.blend_under' do
    expect(red.blend_over(yellow, 0.25)).to eq yellow.blend_over(red, 0.75)
  end

  let(:reds) { [red] * 10 }
  let(:yellows) { [yellow] * 10 }
  let(:wrong_yellows) { [yellow] * 8 }
  let(:oranges) { [orange] * 10 }

  it '.blend_range' do
    expect(Color.blend_range(yellows, reds)).to eq reds
    expect(Color.blend_range(yellows, reds, 0.0)).to eq yellows
    expect(Color.blend_range(yellows, reds, 0.5)).to eq oranges
    expect { Color.blend_range(yellows, wrong_yellows) }
        .to raise_error(Color::BlendRangeMismatch)
  end

  it '.to_s and .from_s' do
    expect(Color.from_s('[190,0,80,10]')).to eq Color.new(190, 0, 80, 10)
    expect(Color.from_s(yellow.to_s)).to eq yellow
  end
end
