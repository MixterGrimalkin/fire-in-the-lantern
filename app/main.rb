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

def scn
  px.scene
end

def neo
  px.neo_pixel
end

def clear
  px.clear
end

def layers
  scn.layers
end

def layer(layer_def)
  scn.layer layer_def
end


logo

if ARGV[0]
  px.load_scene ARGV[0]
  neo.brightness = 255

  puts
  puts '  Press CTRL + C to stop the thing from happening'
  puts

  begin
    while true 
    end
  rescue Interrupt
  end

  px.clear
  px.stop
  neo.close

  puts '  Whatever'
  puts
end


