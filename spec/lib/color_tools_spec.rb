require_relative '../../lib/color'
require_relative '../../lib/color_a'
require_relative '../../lib/color_tools'

RSpec.describe 'ColorTools' do
  include ColorTools

  let(:color_a_1) { ColorA.new Color.new(90,10,10,1), 1.0 }
  let(:color_a_2) { ColorA.new Color.new(30,10,20,2), 1.0 }
  let(:color_a_3) { ColorA.new Color.new(60,10,30,3), 1.0 }
  let(:color_a_4) { ColorA.new nil, 1.0 }

  let(:average_color_a) { ColorA.new Color.new(60,10,20,2), 0.75 }

  it 'computes the average' do
    expect(mix_colors([color_a_1, color_a_2, color_a_3, color_a_4]))
    .to eq average_color_a
  end

end