require_relative '../../fitl/color/colors'

include Colors

RSpec.describe Colors::ColorA do

  let(:empty) { ColorA.new }
  let(:black) { ColorA.new Color.new }
  let(:orange) { ColorA.new(Color.new(200, 150, 0, 0), 0.5) }
  let(:purple) { ColorA.new(Color.new(100, 0, 180, 3), 0.5) }

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

  it '.red .green .blue .white' do
    expect(orange.red).to eq 200
    expect(black.green).to eq 0
    expect(purple.blue).to eq 180
    expect(empty.white).to be_nil
  end

  it '.mix' do
    expect(ColorA.mix([empty, orange, purple, black]))
        .to eq(ColorA.new Color.new(100, 50, 60, 1), 0.5)
  end

  it '.to_s and .from_s' do
    expect(ColorA.from_s('[(190,0,80,10)x0.42]'))
        .to eq ColorA.new(Color.new(190, 0, 80, 10), 0.42)
    expect(ColorA.new(Color.new(209, 109, 180),0.66).to_s).to eq '[(209,109,180,0)x0.66]'
    expect(ColorA.new.to_s).to eq '[x1.0]'
    expect(ColorA.from_s('[x0.9]')).to eq(ColorA.new(nil, 0.9))
    expect(ColorA.from_s(purple.to_s)).to eq purple
  end

  it '.from_string_array' do
    expect(ColorA.from_string_array %w([(10,20,30,40)x1.0] [(50,60,70,80)x0.5]))
    .to eq [ColorA.create(10, 20, 30, 40, 1.0), ColorA.create(50, 60, 70, 80, 0.5)]
  end
end
