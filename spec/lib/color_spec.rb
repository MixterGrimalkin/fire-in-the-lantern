require_relative '../../lib/color'
require_relative '../../lib/color_a'

RSpec.describe Color do

  it 'Caps components' do
    expect(Color.new(300, 0, 0)).to eq Color.new(255, 0, 0)
    expect(Color.new(200, -50, 0)).to eq Color.new(200, 0, 0)
    expect(Color.new(200, 50, 0, 900)).to eq Color.new(200, 50, 0, 255)
  end

  it 'compares ignoring white' do
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3)).to eq true
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3)).to eq false
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 99)).to eq false
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 99)).to eq true
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 99, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 99, 4)).to eq true
  end

  it 'compares with white' do
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 99)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 99)).to eq true
  end

  it '#with_brightness' do
    expect(Color.new(100, 50, 20, 10).with_brightness(0.5))
        .to eq Color.new(50, 25, 10, 5)
  end

  let(:yellow) { Color.new(100, 200, 0) }

  let(:full_white) { Color.new(200, 200, 200, 200) }
  let(:red) { Color.new(200, 0, 0, 0) }

  let(:blue) { Color.new(0, 0, 200) }
  let(:purple) { Color.new(180, 10, 220) }
  let(:purple_20) { ColorA.new(purple, 0.2) }


  it '#blend_over' do
    expect(red.blend_over yellow)
        .to eq red

    expect(red.blend_over yellow, 0)
        .to eq yellow

    expect(red.blend_over yellow, 0.5)
        .to eq Color.new 150, 100, 0

    expect(full_white.blend_over red, 0.25)
        .to eq Color.new 200, 50, 50, 50

    expect(red.blend_over full_white, 0.25)
        .to eq Color.new(200, 150, 150, 150)

  end

  it '#blend_under' do
    expect(red.blend_over(yellow, 0.25)).to eq yellow.blend_over(red, 0.75)
  end

  it 'creates Color from string' do
    expect(Color.from_s('[190,0,80,10]')).to eq Color.new(190, 0, 80, 10)
    expect(Color.from_s(yellow.to_s)).to eq yellow
  end

  it 'creates ColorA from string' do
    expect(ColorA.from_s('([190,0,80,10]x0.42)'))
        .to eq ColorA.new(Color.new(190, 0, 80, 10), 0.42)
    expect(ColorA.from_s(purple_20.to_s)).to eq purple_20
  end

end
