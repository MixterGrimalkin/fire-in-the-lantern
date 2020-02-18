require_relative '../../classes/neo_pixel_std_out'

RSpec.describe NeoPixelStdOut do

  let(:neo_pixel) { NeoPixelStdOut.new 4 }

  it 'renders' do
    expect{ neo_pixel.render }.to output("....\n").to_stdout
    neo_pixel.set 1, Color.new(80)
    neo_pixel.set 2, Color.new(180)
    neo_pixel.set 3, Color.new(255)
    expect{ neo_pixel.render }.to output(".-=#\n").to_stdout
    expect{ neo_pixel.all_on }.to output("####\n").to_stdout
    expect{ neo_pixel.all_off }.to output("....\n").to_stdout
  end

end