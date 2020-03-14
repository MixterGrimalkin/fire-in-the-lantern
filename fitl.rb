require_relative 'lib/color'
require_relative 'lib/color_tools'
require_relative 'lib/utils'
require_relative 'pixelator/pixelator'
require_relative 'neo_pixel/neo_pixel'
require_relative 'neo_pixel/text_neo_pixel'
require_relative 'neo_pixel/http_neo_pixel'
require_relative 'neo_pixel/osc_neo_pixel'
require_relative 'neo_pixel/ws_neo_pixel'
require 'yaml'

include Colors
include Utils

def px
  @px ||= Pixelator.from_config('config/fitl.yml').start
end

logo

if (options = ENV['OPTIONS'])
  puts "   px = #{px.inspect}\n\n" if options.include?('-init')
end
