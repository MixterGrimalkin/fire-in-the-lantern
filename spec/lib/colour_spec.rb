require './lib/colour'

include Fitl

RSpec.describe Colour do

  let(:black) { Colour.new }
  let(:full_white) { Colour.new(200, 200, 200, 200) }
  let(:red) { Colour.new(200, 0, 0, 0) }
  let(:yellow) { Colour.new(100, 200, 0) }
  let(:orange) { Colour.new 150, 100, 0 }
  let(:purple) { Colour.new(100, 0, 180, 3, alpha: 0.5) }

  it '.==' do
    expect(red).to eq Colour.new(200, 0, 0)
    expect(red).not_to eq Colour.new(200, 0, 0, 1)
    expect(red).not_to eq Colour.new(200, 0, 1, 0)
    expect(red).not_to eq Colour.new(200, 1, 0, 0)
    expect(red).not_to eq Colour.new(201, 0, 0, 0)
    expect(red).not_to eq Colour.new(200, 0, 0, 0, alpha: 0.1)
  end

  it '.initialize' do
    expect(Colour.new).to eq Colour.new(0, 0, 0, 0, alpha: 1.0)
    expect(Colour.new 127).to eq Colour.new(127, 127, 127, 0, alpha: 1.0)
    expect(Colour.new alpha: 0.5).to eq Colour.new(0, 0, 0, 0, alpha: 0.5)
  end

  it '.clip' do
    expect(Colour.new(300, 0, 0)).to eq Colour.new(255, 0, 0)
    expect(Colour.new(200, -50, 0)).to eq Colour.new(200, 0, 0)
    expect(Colour.new(200, 50, 0, 900)).to eq Colour.new(200, 50, 0, 255)
  end

  it '.components' do
    expect(purple.components).to eq [100, 0, 180, 3]
  end

  it '.override' do
    expect(
        yellow.override(red: 55, blue: 99, alpha: 0.3)
    ).to(
        eq Colour.new(55, 200, 99, 0, alpha: 0.3)
    )
    expect(
        yellow.override(white: 5)
    ).to(
        eq Colour.new(100, 200, 0, 5, alpha: 1.0)
    )
  end

  it '.adjust' do
    expect(
        yellow.adjust(red: -50, green: -150, blue: 50, white: 50, alpha: -0.5)
    ).to(
        eq Colour.new(50, 50, 50, 50, alpha: 0.5)
    )
  end

  it '.normalize' do
    expect(
        Colour.new(100, 50, 90, 10, alpha: 0.9).normalize
    ).to(
        eq Colour.new(255, 128, 230, 26, alpha: 0.9)
    )
    expect(
        Colour.new(19, 55, 255, 194, alpha: 0.4).normalize
    ).to(
        eq Colour.new(19, 55, 255, 194, alpha: 0.4)
    )
  end

  # Addition

  it '.+ with one or both alphas == 1.0' do
    expect(
        Colour.new(10) + Colour.new(20)
    ).to(
        eq Colour.new(30, 30, 30, 0, alpha: 1.0)
    )
    expect(
        Colour.new(10) + Colour.new(20, alpha: 0.5)
    ).to(
        eq Colour.new(20, 20, 20, 0, alpha: 1.0)
    )
    expect(
        Colour.new(10, alpha: 0.5) + Colour.new(20)
    ).to(
        eq Colour.new(25, 25, 25, 0, alpha: 1.0)
    )
  end

  it '.+ with one or both alphas == 0.0' do
    expect(
        Colour.new(10, alpha: 0.0) + Colour.new(20, alpha: 0.0)
    ).to(
        eq Colour.new(10, 10, 10, 0, alpha: 0.0)
    )
    expect(
        Colour.new(10) + Colour.new(20, alpha: 0.0)
    ).to(
        eq Colour.new(10, 10, 10, 0, alpha: 1.0)
    )
    expect(
        Colour.new(10, alpha: 0.0) + Colour.new(20)
    ).to(
        eq Colour.new(20, 20, 20, 0, alpha: 1.0)
    )
  end

  it '.+ with mixed alphas' do
    expect(
        Colour.new(10, alpha: 0.2) + Colour.new(20, alpha: 0.5)
    ).to(
        eq Colour.new(22, 22, 22, 0, alpha: 0.5)
    )
    expect(
        Colour.new(10, alpha: 0.6) + Colour.new(20, alpha: 0.2)
    ).to(
        eq Colour.new(14, 14, 14, 0, alpha: 0.6)
    )
  end

  # Subtraction

  it '.- with one or both alphas == 1.0' do
    expect(
        Colour.new(80) - Colour.new(30)
    ).to(
        eq Colour.new(50, 50, 50, 0, alpha: 1.0)
    )
    expect(
        Colour.new(80) - Colour.new(30, alpha: 0.5)
    ).to(
        eq Colour.new(65, 65, 65, 0, alpha: 1.0)
    )
    expect(
        Colour.new(80, alpha: 0.5) - Colour.new(30)
    ).to(
        eq Colour.new(50, 50, 50, 0, alpha: 0.5)
    )
  end

  it '.- with one or both alphas == 0.0' do
    expect(
        Colour.new(80, alpha: 0.0) - Colour.new(30, alpha: 0.0)
    ).to(
        eq Colour.new(80, 80, 80, 0, alpha: 0.0)
    )
    expect(
        Colour.new(80) - Colour.new(30, alpha: 0.0)
    ).to(
        eq Colour.new(80, 80, 80, 0, alpha: 1.0)
    )
    expect(
        Colour.new(80, alpha: 0.0) - Colour.new(30)
    ).to(
        eq Colour.new(50, 50, 50, 0, alpha: 0.0)
    )
  end

  it '.- with mixed alphas' do
    expect(
        Colour.new(80, alpha: 0.2) - Colour.new(30, alpha: 0.5)
    ).to(
        eq Colour.new(65, 65, 65, 0, alpha: 0.2)
    )
    expect(
        Colour.new(80, alpha: 0.6) - Colour.new(30, alpha: 0.2)
    ).to(
        eq Colour.new(74, 74, 74, 0, alpha: 0.6)
    )
  end

  # Other Maths Ops

  it '.*' do
    expect(Colour.new(100, 50, 20, 10) * 0.5)
        .to eq Colour.new(50, 25, 10, 5)
    expect(Colour.new(100, 50, 20, 10, alpha: 0.3) * 3)
        .to eq Colour.new(255, 150, 60, 30, alpha: 0.3)
  end

  it './' do
    expect(Colour.new(100, 50, 20, 10) / 2)
        .to eq Colour.new(50, 25, 10, 5)
    expect(Colour.new(100, 50, 20, 10, alpha: 0.7) / 20)
        .to eq Colour.new(5, 2, 1, 0, alpha: 0.7)
  end

  it '.-@' do
    expect(-Colour.new(255, 0, 0))
        .to eq Colour.new(0, 255, 255, 255)
    expect(-Colour.new(0, 255, 0, 0, alpha: 0.4))
        .to eq Colour.new(255, 0, 255, 255, alpha: 0.4)
  end

  # Blending

  it '.blend_over' do
    expect(red.blend_over yellow)
        .to eq red
    expect(red.blend_over yellow, 0.5)
        .to eq Colour.new(150, 100, 0, 0, alpha: 1.0)
    expect(
        Colour.new(20, 100, 200, alpha: 0.5).blend_over(red)
    ).to(
        eq Colour.new(110, 50, 100, 0, alpha: 1.0)
    )
    expect(
        Colour.new(20, 100, 200, alpha: 0.5).blend_over(red, 0.5)
    ).to(
        eq Colour.new(155, 25, 50, 0, alpha: 1.0)
    )
    expect(
        Colour.new(200, alpha: 0.2).blend_over(Colour.new(100, alpha: 0.6))
    ).to(
        eq Colour.new(128, 128, 128, 0, alpha: 0.6)
    )
  end

  it '.blend_under' do
    expect(red.blend_over(yellow, 0.25)).to eq yellow.blend_over(red, 0.75)
  end

  let(:reds) { [red] * 10 }
  let(:yellows) { [yellow] * 10 }
  let(:wrong_yellows) { [yellow] * 8 }
  let(:oranges) { [orange] * 10 }

  it '.blend_range' do
    expect(Colour.blend_range(yellows, reds)).to eq reds
    expect(Colour.blend_range(yellows, reds, 0.0)).to eq yellows
    expect(Colour.blend_range(yellows, reds, 0.5)).to eq oranges
    expect { Colour.blend_range(yellows, wrong_yellows) }
        .to raise_error(Colour::BlendRangeMismatch)

    expect(Colour.blend_range [red, black, yellow], [red, red, full_white], 0.5)
        .to eq [
                   Colour.new(200, 0, 0, 0, alpha: 1.0),
                   Colour.new(100, 0, 0, 0, alpha: 1.0),
                   Colour.new(150, 200, 100, 100, alpha: 1.0)
               ]
  end

  it '.mix' do
    expect(Colour.mix([nil, orange, purple, black]))
        .to eq Colour.new(66, 33, 30, 0, alpha: 0.625)
  end

  # String

  it '.to_s' do
    expect(Colour.new(55).to_s).to eq '(55,55,55,0)x1.0'
    expect(Colour.new(12, 34, 56, 78, alpha: 0.9).to_s).to eq '(12,34,56,78)x0.9'
  end

  it '.from_s' do
    expect(Colour.from_s('(11,22,33,44)x0.55')).to eq Colour.new(11, 22, 33, 44, alpha: 0.55)
    expect(Colour.from_s('(11,22,33,44)')).to eq Colour.new(11, 22, 33, 44, alpha: 1.0)
    expect(Colour.from_s('(11,22,33)')).to eq Colour.new(11, 22, 33, 0, alpha: 1.0)

    expect(Colour.from_s(yellow.to_s)).to eq yellow
    expect(Colour.from_s(full_white.to_s)).to eq full_white
  end

  it '.from_string_array' do
    expect(
        Colour.from_string_array %w((200,0,0,0)x1.0 (100,200,0,0)x1.0 (0,0,0,0)x1.0)
    ).to(
        eq [red, yellow, black]
    )
  end
end