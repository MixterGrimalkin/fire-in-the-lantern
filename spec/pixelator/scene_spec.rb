require_relative '../../fitl/neo_pixel/neo_pixel'
require_relative '../../fitl/pixelator/pixelator'

RSpec.describe Scene do

  let(:neo_pixel) { NeoPixel.new pixel_count: 6 }
  let(:pixelator) { Pixelator.new neo_pixel: neo_pixel }




end