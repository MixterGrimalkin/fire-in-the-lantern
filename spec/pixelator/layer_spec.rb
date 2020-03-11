require_relative '../../pixelator/layer'
require_relative '../../pixelator/pixelator'
require_relative '../../neo_pixel/neo_pixel'
require_relative '../../support/color_constants'

require 'byebug'

RSpec.describe Layer do

  let(:neo_pixel) { NeoPixel.new(8) }

  let(:pixelator) { Pixelator.new neo_pixel }

  subject(:layer) { pixelator.layer new_layer: (2..5) }

  it '.initializes correctly' do
    expect(layer).to be_a Layer
    expect(layer).to eq pixelator[:new_layer]
    expect(layer).to eq pixelator.new_layer
    expect(layer.contents).to eq [nil, nil, nil, nil]
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
    layer.fill red, 1
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

    layer.global_opacity = 0.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, dk_blue, dk_blue, dk_blue, dk_blue, blk, blk]

    layer.global_opacity = 0.25
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

  it 'draws a symmetric gradient with an even size' do
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

  it 'draws a symmetric gradient with an odd size' do
    pixelator.layer a: (0..6)
    pixelator.a.gradient red: [180, 0], green: [10, 100], blue: [7, 10], sym: true
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

  it 'scrolls' do
    layer.fill red

    layer.scroll_by 1
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, blk, red, red, red, red, blk]

    layer.scroll_by -4
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [red, red, red, blk, blk, blk, blk, red]
  end

  it 'sets scroll delta' do
    layer.fill red

    layer.update_scroll 1
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [blk, blk, red, red, red, red, blk, blk]

    layer.start_scroll 1
    layer.update_scroll 3.5
    pixelator.render
    expect(neo_pixel.contents)
        .to eq [red, blk, blk, blk, blk, red, red, red]

    layer.start_scroll -2
    layer.update_scroll 6.5
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