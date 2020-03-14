require_relative '../../neo_pixel/text_neo_pixel'

RSpec.describe TextNeoPixel do

  let(:neo_pixel) { TextNeoPixel.new 4 }

  it 'renders' do
    expect{ neo_pixel.render }.to output("....\n").to_stdout
    neo_pixel[1] = Color.new(80)
    neo_pixel[2] = Color.new(180)
    neo_pixel[3] = Color.new(255)
    expect{ neo_pixel.render }.to output(".-=#\n").to_stdout
    expect{ neo_pixel.on }.to output("####\n").to_stdout
    expect{ neo_pixel.off }.to output("....\n").to_stdout
  end

end