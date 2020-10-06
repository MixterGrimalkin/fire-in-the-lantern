require './main/requirer'
include Fitl
include Colours

RSpec.describe Scene do

  let(:neo_pixel) { NeoPixel.new pixel_count: 6 }
  let(:pixelator) { Pixelator.new neo_pixel: neo_pixel }




end