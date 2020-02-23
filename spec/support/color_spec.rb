require_relative '../../support/color'

RSpec.describe Color do

  it 'compares ignoring white' do
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3)).to eq true
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3)).to eq false
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3) == Color.new(1, 2, 99)).to eq false
    expect(Color.new(1, 2, 3) != Color.new(1, 2, 99)).to eq true
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 99, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 99, 4)).to eq true
  end

  it 'compares with white' do
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 4)).to eq true
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 4)).to eq false
    expect(Color.new(1, 2, 3, 4) == Color.new(1, 2, 3, 99)).to eq false
    expect(Color.new(1, 2, 3, 4) != Color.new(1, 2, 3, 99)).to eq true
  end

  it '#with_brightness' do
    expect(Color.new(100, 50, 20, 10).with_brightness(0.5))
        .to eq Color.new(50, 25, 10, 5)
  end

  let(:red) { Color.new(200, 0, 0) }
  let(:blue) { Color.new(0, 0, 200) }


  # it '#blend' do
  #   expect()
  # end

end
