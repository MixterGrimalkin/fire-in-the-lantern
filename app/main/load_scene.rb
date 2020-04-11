require_relative 'fire_in_the_lantern'

include FireInTheLantern

unless (scene_name = ARGV[0])
  message 'Specify a Scene to load'
  exit
end

px.start
px.load_scene scene_name

message 'Press CTRL + C to make it stop'
wait_for_interrupt

px.stop
px.clear
neo.off
neo.close

message 'Bye'
