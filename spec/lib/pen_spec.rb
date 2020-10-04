require './lib/pen'

include Fitl
include Colours

RSpec.describe Fitl::Pen do

  it 'creates a color block' do
    expect(Pen.block(RED, 3)).to eq([RED, RED, RED])
  end

  it 'creates multiple blocks' do
    expect(Pen.blocks(RED, 2, BLACK, 2, BLUE, 2))
        .to eq [RED, RED, BLACK, BLACK, BLUE, BLUE]
  end

  it 'repeats a pattern' do
    expect(Pen.repeat(Pen.blocks(RED, 2, BLUE, 1), 3))
        .to eq [RED, RED, BLUE, RED, RED, BLUE, RED, RED, BLUE]
  end

  it 'creates a gradient' do
    expect(Pen.gradient(Colour.new(180, 10, 7),
                        Colour.new(0, 100, 10),
                          size: 4))
        .to eq([Colour.new(180, 10, 7),
                Colour.new(120, 40, 8),
                Colour.new(60, 70, 9),
                Colour.new(0, 100, 10)])
  end

  it 'creates a symmetrical gradient with even size' do
    expect(Pen.gradient(Colour.new(180, 10, 7),
                          Colour.new(0, 100, 10),
                          size: 8,
                          sym: true))
        .to eq([Colour.new(180, 10, 7),
                Colour.new(120, 40, 8),
                Colour.new(60, 70, 9),
                Colour.new(0, 100, 10),
                Colour.new(0, 100, 10),
                Colour.new(60, 70, 9),
                Colour.new(120, 40, 8),
                Colour.new(180, 10, 7)])
  end

  it 'creates a symmetrical gradient with odd size' do
    expect(Pen.gradient(Colour.new(180, 10, 7),
                          Colour.new(0, 100, 10),
                          size: 7,
                          sym: true))
        .to eq([Colour.new(180, 10, 7),
                Colour.new(120, 40, 8),
                Colour.new(60, 70, 9),
                Colour.new(0, 100, 10),
                Colour.new(60, 70, 9),
                Colour.new(120, 40, 8),
                Colour.new(180, 10, 7)])
  end
end
