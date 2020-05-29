require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

unless (scene_name = (ARGV[0] || settings.default_scene))
  message 'Specify a Scene to load'
  exit
end

px.scene_mode
px.start.load_file scene_name

message "Loaded Scene: #{scene_name}"

wait_for_interrupt 'Press CTRL + C to make it stop'

px.stop.clear

neo.off
neo.close

message 'Bye'
