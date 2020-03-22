require_relative '../../pixelator/layer'
require_relative '../../pixelator/pixelator'
require_relative '../../neo_pixel/neo_pixel'
require_relative '../../lib/color_tools'

require 'byebug'

RSpec.describe Layer do

  let(:neo_pixel) { NeoPixel.new(8) }

  let(:pixelator) { Pixelator.new neo_pixel }

  subject(:layer) { pixelator.layer new_layer: (2..5) }

  it '.initializes correctly' do
    expect(layer).to be_a Layer
    expect(layer).to eq pixelator[:new_layer]
    expect(layer.layer_opacity).to eq 1
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


  it 'fill with single color' do
    layer.fill red
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]

    layer.fill red, 0.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dk_red, dk_red, dk_red, dk_red, blk, blk]
  end

  it 'blends with opacity' do
    layer.fill blue

    layer.layer_opacity = 0.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dk_blue, dk_blue, dk_blue, dk_blue, blk, blk]

    layer.layer_opacity = 0.25
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dkr_blue, dkr_blue, dkr_blue, dkr_blue, blk, blk]


  end

  it 'draws a gradient' do
    layer.gradient red: [180, 0], green: [10, 100], blue: [7, 10]
    pixelator.render
    expect(neo_pixel.contents)
        .to eq([blk, blk,
                Color.new(180, 10, 7),
                Color.new(120, 40, 8),
                Color.new(60, 70, 9),
                Color.new(0, 100, 10),
                blk, blk])
  end

  it 'draws a sym gradient with even size' do
    pixelator.base.gradient red: [180, 0], green: [10, 100], blue: [7, 10], sym: true
    pixelator.render
    expect(neo_pixel.contents)
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
    pixelator.layer a: (0..6)
    pixelator[:a].gradient red: [180, 0], green: [10, 100], blue: [7, 10], sym: true
    pixelator.render
    expect(neo_pixel.contents)
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
    pixelator.base.gradient red: 100, green: [0,30], start: 2, width: 4
    pixelator.render
    expect(neo_pixel.contents)
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
    pixelator.base.gradient red: 100, green: [0,30], start: 1, width: 5, sym: true
    pixelator.render
    expect(neo_pixel.contents)
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
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]

    layer.scroller.start 1
    layer.scroller.update 3.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [red, blk, blk, blk, blk, red, red, red]

    layer.scroller.start -2
    layer.scroller.update 6.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]
  end

  it 'sets opacity by pixel' do
    pixelator.base.fill red
    layer.set 0, blue, 0.0
    layer.set 1, blue, 0.25
    layer.set 2, blue, 0.5
    layer.set 3, blue
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [red, red, red, red_purple, purple, blue, red, red]
  end

  it 'throws an error when pixel out of range' do
    expect{ layer.set 4, red }.to raise_error(PixelOutOfRangeError)
    expect{ layer[-1] = red }.to raise_error(PixelOutOfRangeError)
  end

end