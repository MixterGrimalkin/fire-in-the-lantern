require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

unless (media_type = ARGV[0]) && (media_name = ARGV[1])
  message 'Usage: load.sh [layer|cue|scene|story] [name] [-play]'
  exit
end

px.send("#{media_type}_mode".to_sym)

px.start.build media_name

message "Loaded #{media_type}: #{media_name}"

if (ARGV.include?('-play') || settings.auto_play) && px.get.respond_to?(:play)
  px.get.play
end

wait_for_interrupt 'Press CTRL + C to make it stop'

px.stop.clear

neo.off
neo.close

message 'Bye'
