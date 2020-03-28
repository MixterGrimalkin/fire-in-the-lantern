require_relative '../../pixelator/layer'
require_relative '../../pixelator/pixelator'
require_relative '../../neo_pixel/neo_pixel'
require_relative '../../lib/color_tools'

# require 'byebug'

RSpec.describe Layer do

  let(:neo) { NeoPixel.new(8) }

  let(:px) { Pixelator.new neo }

  subject(:layer) { px.layer new_layer: (2..5) }

  it 'initializes correctly' do
    expect(layer).to be_a Layer
    expect(layer).to eq px[:new_layer]
    expect(layer).to eq px.scene.new_layer
    expect(layer.opacity).to eq 1
    expect(layer.color_array).to eq [nil, nil, nil, nil]
    expect(layer.alpha_array).to eq [1, 1, 1, 1]
  end

  let(:blk) { Color.new }
  let(:red) { Color.new 200, 0, 0 }
  let(:dk_red) { Color.new 100, 0, 0 }

  let(:blue) { Color.new 0, 0, 200 }
  let(:dk_blue) { Color.new 0, 0, 100 }
  let(:dkr_blue) { Color.new 0, 0, 50 }

  let(:purple) { Color.new 100, 0, 100 }
  let(:red_purple) { Color.new 150, 0, 50 }


  it 'fills with a single color' do
    layer.fill red
    px.render
    expect(neo.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]
  end

  it 'applies layer opacity' do
    layer.fill blue

    layer.opacity = 0.5
    px.render
    expect(neo.contents)
        .to eq [blk, blk, dk_blue, dk_blue, dk_blue, dk_blue, blk, blk]

    layer.opacity = 0.25
    px.render
    expect(neo.contents)
        .to eq [blk, blk, dkr_blue, dkr_blue, dkr_blue, dkr_blue, blk, blk]
  end

  it 'draws a gradient' do
    layer.gradient red: [180, 0], green: [10, 100], blue: [7, 10]
    px.render
    expect(neo.contents)
        .to eq([blk, blk,
                Color.new(180, 10, 7),
                Color.new(120, 40, 8),
                Color.new(60, 70, 9),
                Color.new(0, 100, 10),
                blk, blk])
  end

  it 'draws a sym gradient with even size' do
    px.base.gradient red: [180, 0], green: [10, 100], blue: [7, 10], sym: true
    px.render
    expect(neo.contents)
        .to eq([Color.new(180, 10, 7),
                Color.new(120, 40, 8),
                Color.new(60, 70, 9),
                Color.new(0, 100, 10),
                Color.new(0, 100, 10),
                Color.new(60, 70, 9),
                Color.new(120, 40, 8),
                Color.new(180, 10, 7)])
  end

  it 'draws a sym gradient with odd size' do
    px.layer a: (0..6)
    px[:a].gradient red: [180, 0], green: [10, 100], blue: [7, 10], sym: true
    px.render
    expect(neo.contents)
        .to eq([Color.new(180, 10, 7),
                Color.new(120, 40, 8),
                Color.new(60, 70, 9),
                Color.new(0, 100, 10),
                Color.new(60, 70, 9),
                Color.new(120, 40, 8),
                Color.new(180, 10, 7),
                blk
               ])

  end

  it 'draws a smaller gradient' do
    px.base.gradient red: 100, green: [0,30], start: 2, width: 4
    px.render
    expect(neo.contents)
        .to eq([blk,
                blk,
                Color.new(100, 0, 0),
                Color.new(100, 10, 0),
                Color.new(100, 20, 0),
                Color.new(100, 30, 0),
                blk,
                blk
               ])
  end

  it 'draws a smaller sym gradient' do
    px.base.gradient red: 100, green: [0,30], start: 1, width: 5, sym: true
    px.render
    expect(neo.contents)
        .to eq([blk,
                Color.new(100, 0, 0),
                Color.new(100, 15, 0),
                Color.new(100, 30, 0),
                Color.new(100, 15, 0),
                Color.new(100, 0, 0),
                blk,
                blk
               ])
  end

  it 'scrolls' do
    layer.fill red

    layer.scroller.update 1
    px.render
    expect(neo.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]

    layer.scroller.start 1
    layer.scroller.update 3.5
    px.render
    expect(neo.contents)
        .to eq [red, blk, blk, blk, blk, red, red, red]

    layer.scroller.start -2
    layer.scroller.update 6.5
    px.render
    expect(neo.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]
  end

  it 'sets opacity by pixel' do
    px.base.fill red
    layer.set 0, blue, 0.0
    layer.set 1, blue, 0.25
    layer.set 2, blue, 0.5
    layer.set 3, blue
    px.render
    expect(neo.contents)
        .to eq [red, red, red, red_purple, purple, blue, red, red]
  end

  it 'throws an error when pixel out of range' do
    expect{ layer.set 4, red }.to raise_error(PixelOutOfRangeError)
    expect{ layer[-1] = red }.to raise_error(PixelOutOfRangeError)
  end

end