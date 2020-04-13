require_relative '../../app/neo_pixel/neo_pixel'
require_relative '../../app/pixelator/pixelator'

RSpec.describe Scene do

  let(:neo) { NeoPixel.new pixel_count: 10 }
  let(:px) { Pixelator.new neo_pixel: neo }
  let(:scene) { px.scene }

  let(:all_pixels) { [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] }

  let(:black) { Color.new }
  let(:white) { Color.new 255 }
  let(:red) { Color.new 255, 0, 0 }
  let(:blue) { Color.new 0, 0, 255 }

  it 'initializes the base layer' do
    expect(scene[:base].canvas).to eq all_pixels
    expect(scene.base.canvas).to eq all_pixels
    expect(scene.base.color_array).to eq [Color.new]*10
    expect(scene.base.alpha_array).to eq [1.0]*10
  end

  it 'can define a new layer' do
    scene.layer :the_lot
    expect(scene[:the_lot].canvas).to eq all_pixels
  end

  it 'can define a layer by range' do
    scene.layer :mid_four, canvas: (4..7)
    expect(scene[:mid_four].canvas)
        .to eq [4, 5, 6, 7]
  end

  it 'can define a layer by array' do
    scene.layer :those_three, canvas: [1, 6, 9]
    expect(scene[:those_three].canvas)
        .to eq [1, 6, 9]
  end

  it 'can define a layer by proc' do
    scene.layer :evens, canvas: proc { |p| p % 2 == 0 }
    expect(scene[:evens].canvas)
        .to eq [0, 2, 4, 6, 8]
  end

  it 'defines a method for new layers' do
    scene.layer :odds, canvas: proc { |p| p % 2 != 0 }
    expect(scene.odds).to eq scene[:odds]
  end

  context '#hide and #show' do
    let!(:layer_1) { scene.layer :a, background: blue }
    let!(:layer_2) { scene.layer :b, canvas: [2, 5, 7], background: red }

    it 'initializes with all layers visible' do
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

    it 'hides a single layer' do
      layer_1.hide
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [black, black, red, black, black,
                  red, black, red, black, black]
    end

    it 'solos a single layer' do
      expect { scene.solo :not_exist }.to raise_error(LayerNotFound)

      scene.solo(:b)
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [black, black, red, black, black,
                  red, black, red, black, black]
    end

    it 'hides all layers' do
      scene.hide_all
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]
    end

    it 'shows a single layer' do
      scene.hide_all
      px.render

      expect(layer_1.visible).to eq false
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      layer_1.show
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq false
      expect(neo.contents)
          .to eq [blue, blue, blue, blue, blue,
                  blue, blue, blue, blue, blue]
    end

    it 'shows all layers' do
      scene.hide_all
      px.render
      expect(neo.contents)
          .to eq [black, black, black, black, black,
                  black, black, black, black, black]

      scene.show_all
      px.render

      expect(layer_1.visible).to eq true
      expect(layer_2.visible).to eq true
      expect(neo.contents)
          .to eq [blue, blue, red, blue, blue,
                  red, blue, red, blue, blue]
    end

  end

  context 'Layer re-ordering' do
    before do
      scene.layer(:layer_1, canvas: [1, 5, 9], background: red)
      scene.layer(:layer_2, background: blue)
      scene.layer(:layer_3, canvas: [2, 5, 7], background: white)
      px.render
      expect(neo.contents)
          .to eq [blue, blue, white, blue, blue,
                  white, blue, white, blue, blue]
    end

    it '#put_top' do
      expect { scene.put_top(:not_exist) }.to raise_error(LayerNotFound)

      scene.put_top(:layer_1)

      px.render
      expect(neo.contents)
          .to eq [blue, red, white, blue, blue,
                  red, blue, white, blue, red]
    end

    it '#put_bottom' do
      expect { scene.put_bottom(:not_exist) }.to raise_error(LayerNotFound)

      scene.put_bottom(:layer_3)

      px.render
      expect(neo.contents)
          .to eq [blue, blue, blue, blue, blue,
                  blue, blue, blue, blue, blue]
    end
  end
  
end