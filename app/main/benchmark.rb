require_relative 'fire_in_the_lantern'

include FireInTheLantern

test_scenes = ARGV.empty? ? %w(water swirls other_swirls) : ARGV
wait = 3

factory adapter_override: :BenchmarkNeoPixel

puts "Running Pixelator benchmark @ #{px.fps}fps . . . ."
puts
neo.start_recording 'startup'
px.start
sleep wait

test_scenes.each do |scene_name|
  neo.start_recording "fade to #{scene_name}"
  px.load_scene scene_name, crossfade: wait
  sleep wait

  neo.start_recording scene_name
  sleep wait
end

neo.stop_recording

puts
puts 'Average refresh times and frame-rates:'
neo.print_recordings
puts
puts 'Done'
puts
