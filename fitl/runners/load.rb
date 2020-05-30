require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

unless (media_type = ARGV[0]) && (media_name = ARGV[1])
  message 'Usage: load.sh [layer|cue|scene|story] [name]'
  exit
end

px.send("#{media_type}_mode".to_sym)

px.start.load_file media_name

message "Loaded #{media_type}: #{media_name}"

wait_for_interrupt 'Press CTRL + C to make it stop'

px.stop.clear

neo.off
neo.close

message 'Bye'
