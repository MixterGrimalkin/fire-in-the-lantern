# Usage: load.sh [layer|cue|scene|story] [name] [-play]

require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

begin
  media_type = ARGV[0] || settings.default_media_type
  media_name = ARGV[1] || settings.default_media_name

  px.send("#{media_type}_mode").start.build(media_name)

rescue Assets::BadMedia => e
  message e.message

rescue NoMethodError
  message "#{media_type} is not a valid media type"

else
  message "Loaded #{media_type.downcase} #{media_name}"

  if (ARGV.include?('-play') || settings.auto_play) && px.get.respond_to?(:play)
    px.get.play
  end

  message 'Press CTRL + C to make it stop'

  wait_for_interrupt

  px.stop.clear
  neo.off
  neo.close
end

message 'Bye'
