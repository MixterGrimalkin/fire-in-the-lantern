require_relative '../../fitl/lib/color'
require_relative '../../fitl/lib/color_a'

RSpec.describe ColorA do

  it '.initialize' do
    expect(ColorA.new).to eq(ColorA.new(nil, 1.0))
  end

  it '.create' do
    expect(ColorA.create).to eq(ColorA.new(Color.new, 1.0))
    expect(ColorA.create(190, 90, 45)).to eq(ColorA.new(Color.new(190, 90, 45, 0), 1.0))
    expect(ColorA.create(190, 90, 45, 100)).to eq(ColorA.new(Color.new(190, 90, 45, 100), 1.0))
    expect(ColorA.create(190, 90, 45, 100, 0.6)).to eq(ColorA.new(Color.new(190, 90, 45, 100), 0.6))
  end

  it '.cast' do
    expect(ColorA.cast(ColorA.new(Color.new))).to eq(ColorA.new(Color.new, 1.0))
    expect(ColorA.cast(Color.new)).to eq(ColorA.new(Color.new, 1.0))
  end

  let(:empty) { ColorA.new }
  let(:black) { ColorA.new Color.new }
  let(:orange) { ColorA.new(Color.new(200, 150, 0, 0), 0.5) }
  let(:purple) { ColorA.new(Color.new(100, 0, 180, 3), 0.5) }

  it 'color component access' do
    expect(orange.red).to eq 200
    expect(black.green).to eq 0
    expect(purple.blue).to eq 180
    expect(empty.white).to be_nil
  end

  it '.mix' do
    expect(ColorA.mix([empty, orange, purple, black]))
        .to eq(ColorA.new Color.new(100, 50, 60, 1), 0.5)
  end

  let(:purple_20) { ColorA.new(Color.new(180, 10, 220), 0.2) }

  it '.to_s and .from_s' do
    expect(ColorA.from_s('([190,0,80,10]x0.42)'))
        .to eq ColorA.new(Color.new(190, 0, 80, 10), 0.42)
    expect(ColorA.from_s(purple_20.to_s)).to eq purple_20
  end

end
