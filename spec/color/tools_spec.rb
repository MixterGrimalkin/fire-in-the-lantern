require_relative '../../fitl/color/colors'

include Colors

RSpec.describe Colors::Tools do

  let(:red) { RED }
  let(:red_a) { ColorA.cast(RED) }
  let(:blue) { BLUE }
  let(:blue_a) { ColorA.cast(BLUE) }

  it 'creates a color block' do
    expect(Tools.block(red, 5)).to eq([red_a] * 5)
    expect(Tools.block(red_a, 5)).to eq([red_a] * 5)
  end

  it 'creates multiple blocks' do
    expect(Tools.blocks(red, 2, blue, 2, blue_a, 2))
        .to eq [red_a, red_a, blue_a, blue_a, blue_a, blue_a]
  end

  it 'repeats a pattern' do
    expect(Tools.repeat(Tools.blocks(red, 2, blue, 1), 3))
        .to eq [red_a, red_a, blue_a, red_a, red_a, blue_a, red_a, red_a, blue_a]
  end

  it 'creates a gradient from Colors' do
    expect(Tools.gradient(Color.new(180, 10, 7),
                          Color.new(0, 100, 10),
                          size: 4))
        .to eq([ColorA.create(180, 10, 7),
                ColorA.create(120, 40, 8),
                ColorA.create(60, 70, 9),
                ColorA.create(0, 100, 10)])
  end

  it 'creates a gradient from ColorAs' do
    expect(Tools.gradient(ColorA.new(Color.new(180, 10, 7), 0.0),
                          ColorA.new(Color.new(0, 100, 10), 1.0),
                          size: 4))
        .to eq([ColorA.create(180, 10, 7, 0, 0.0),
                ColorA.create(120, 40, 8, 0, 0.3333333333333333),
                ColorA.create(60, 70, 9, 0, 0.6666666666666666),
                ColorA.create(0, 100, 10, 0, 1.0)])
  end

  it 'creates a symmetrical gradient with even size' do
    expect(Tools.gradient(Color.new(180, 10, 7),
                          Color.new(0, 100, 10),
                          size: 8,
                          sym: true))
        .to eq([ColorA.create(180, 10, 7),
                ColorA.create(120, 40, 8),
                ColorA.create(60, 70, 9),
                ColorA.create(0, 100, 10),
                ColorA.create(0, 100, 10),
                ColorA.create(60, 70, 9),
                ColorA.create(120, 40, 8),
                ColorA.create(180, 10, 7)])
  end

  it 'creates a symmetrical gradient with odd size' do
    expect(Tools.gradient(Color.new(180, 10, 7),
                          Color.new(0, 100, 10),
                          size: 7,
                          sym: true))
        .to eq([ColorA.create(180, 10, 7),
                ColorA.create(120, 40, 8),
                ColorA.create(60, 70, 9),
                ColorA.create(0, 100, 10),
                ColorA.create(60, 70, 9),
                ColorA.create(120, 40, 8),
                ColorA.create(180, 10, 7)])
  end

  # it 'creates a color wheel' do
  #   expect(ColorTools.wheel(Color.new(100, 0, 0),
  #                           Color.new(0, 100, 0),
  #                           Color.new(100, 0, 0),
  #                           size: 9))
  #       .to eq([ColorA.create(100, 0, 0),
  #               ColorA.create(75, 25, 0),
  #               ColorA.create(50, 50, 0),
  #               ColorA.create(25, 75, 0),
  #               ColorA.create(0, 100, 0),
  #               ColorA.create(25, 75, 0),
  #               ColorA.create(50, 50, 0),
  #               ColorA.create(75, 25, 0),
  #               ColorA.create(100, 0, 0)])
  # end

end
