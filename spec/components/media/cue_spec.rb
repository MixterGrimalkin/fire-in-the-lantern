require './main/requirer'
include Fitl
include Colours

RSpec.describe Cue do

  subject(:cue) { Cue.new size: 5 }

  let(:base_layer) { [black] * 5 }

  let(:black) { Colour.new }
  let(:white) { Colour.new 255 }
  let(:red) { Colour.new 255, 0, 0 }
  let(:blue) { Colour.new 0, 0, 255 }

  it 'initializes' do
    expect(cue.playing?).to eq false
    expect(cue.render_over(base_layer))
        .to eq base_layer
  end

  let(:layer_1) { Layer.new(name: 'this_layer', size: 50, fill: white) }
  let(:layer_2) { Layer.new(name: 'other_layer', size: 50, fill: red) }

  it 'adds layers' do
    cue.add_layer layer_1
    cue.add_layer layer_2, canvas: [0, 2]
    expect(cue.layers.size).to eq 2
    expect(cue.layer(:this_layer)).to eq layer_1
    expect(cue.render_over(base_layer))
        .to eq base_layer

    cue.play
    expect(cue.playing?).to eq true

    expect(cue.render_over(base_layer))
        .to eq [red, white, red, white, white]

    cue.stop
    expect(cue.playing?).to eq false

    expect(cue.render_over(base_layer))
        .to eq base_layer
  end

  # context '#hide and #show' do
  #   let!(:layer_1) { scene.layer :a, background: blue }
  #   let!(:layer_2) { scene.layer :b, canvas: [2, 5, 7], background: red }
  #
  #   it 'initializes with all layers visible' do
  #     px.render
  #
  #     expect(layer_1.visible).to eq true
  #     expect(layer_2.visible).to eq true
  #     expect(neo.contents)
  #         .to eq [blue, blue, red, blue, blue,
  #                 red, blue, red, blue, blue]
  #   end
  #
  #   it 'hides a single layer' do
  #     layer_1.hide
  #     px.render
  #
  #     expect(layer_1.visible).to eq false
  #     expect(layer_2.visible).to eq true
  #     expect(neo.contents)
  #         .to eq [black, black, red, black, black,
  #                 red, black, red, black, black]
  #   end
  #
  #   it 'solos a single layer' do
  #     expect { scene.solo :not_exist }.to raise_error(LayerNotFound)
  #
  #     scene.solo(:b)
  #     px.render
  #
  #     expect(layer_1.visible).to eq false
  #     expect(layer_2.visible).to eq true
  #     expect(neo.contents)
  #         .to eq [black, black, red, black, black,
  #                 red, black, red, black, black]
  #   end
  #
  #   it 'hides all layers' do
  #     scene.hide_all
  #     px.render
  #
  #     expect(layer_1.visible).to eq false
  #     expect(layer_2.visible).to eq false
  #     expect(neo.contents)
  #         .to eq [black, black, black, black, black,
  #                 black, black, black, black, black]
  #   end
  #
  #   it 'shows a single layer' do
  #     scene.hide_all
  #     px.render
  #
  #     expect(layer_1.visible).to eq false
  #     expect(layer_2.visible).to eq false
  #     expect(neo.contents)
  #         .to eq [black, black, black, black, black,
  #                 black, black, black, black, black]
  #
  #     layer_1.show
  #     px.render
  #
  #     expect(layer_1.visible).to eq true
  #     expect(layer_2.visible).to eq false
  #     expect(neo.contents)
  #         .to eq [blue, blue, blue, blue, blue,
  #                 blue, blue, blue, blue, blue]
  #   end
  #
  #   it 'shows all layers' do
  #     scene.hide_all
  #     px.render
  #     expect(neo.contents)
  #         .to eq [black, black, black, black, black,
  #                 black, black, black, black, black]
  #
  #     scene.show_all
  #     px.render
  #
  #     expect(layer_1.visible).to eq true
  #     expect(layer_2.visible).to eq true
  #     expect(neo.contents)
  #         .to eq [blue, blue, red, blue, blue,
  #                 red, blue, red, blue, blue]
  #   end
  #
  # end
  #
  # context 'Layer re-ordering' do
  #   before do
  #     scene.layer(:layer_1, canvas: [1, 5, 9], background: red)
  #     scene.layer(:layer_2, background: blue)
  #     scene.layer(:layer_3, canvas: [2, 5, 7], background: white)
  #     px.render
  #     expect(neo.contents)
  #         .to eq [blue, blue, white, blue, blue,
  #                 white, blue, white, blue, blue]
  #   end
  #
  #   it '#put_top' do
  #     expect { scene.put_top(:not_exist) }.to raise_error(LayerNotFound)
  #
  #     scene.put_top(:layer_1)
  #
  #     px.render
  #     expect(neo.contents)
  #         .to eq [blue, red, white, blue, blue,
  #                 red, blue, white, blue, red]
  #   end
  #
  #   it '#put_bottom' do
  #     expect { scene.put_bottom(:not_exist) }.to raise_error(LayerNotFound)
  #
  #     scene.put_bottom(:layer_3)
  #
  #     px.render
  #     expect(neo.contents)
  #         .to eq [blue, blue, blue, blue, blue,
  #                 blue, blue, blue, blue, blue]
  #   end
  # end
  #
end