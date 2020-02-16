require_relative '../../support/color'

RSpec.describe Color do

  it 'compares ignoring white' do
    expect(Color.new(1,2,3,4) == Color.new(1,2,3)).to eq true
    expect(Color.new(1,2,3,4) != Color.new(1,2,3)).to eq false
    expect(Color.new(1,2,3) == Color.new(1,2,3,4)).to eq true
    expect(Color.new(1,2,3) != Color.new(1,2,3,4)).to eq false
    expect(Color.new(1,2,3) == Color.new(1,2,99)).to eq false
    expect(Color.new(1,2,3) != Color.new(1,2,99)).to eq true
    expect(Color.new(1,2,3,4) == Color.new(1,2,99,4)).to eq false
    expect(Color.new(1,2,3,4) != Color.new(1,2,99,4)).to eq true
  end

  it 'compares with white' do
    expect(Color.new(1,2,3,4) == Color.new(1,2,3,4)).to eq true
    expect(Color.new(1,2,3,4) != Color.new(1,2,3,4)).to eq false
    expect(Color.new(1,2,3,4) == Color.new(1,2,3,99)).to eq false
    expect(Color.new(1,2,3,4) != Color.new(1,2,3,99)).to eq true
  end

end
