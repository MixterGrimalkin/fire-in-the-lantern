require_relative 'fire_in_the_lantern'

include FireInTheLantern

factory adapter_override: :BenchmarkNeoPixel
neo.render_delay = px.render_period
wait = 3

puts 'Running Benchmark....'
puts
neo.start_recording 'startup'
px.start
sleep wait

test_scenes = ARGV.empty? ? %w(water swirls other_swirls) : ARGV

test_scenes.each do |scene_name|
  neo.start_recording "fade to #{scene_name}"
  px.load_scene scene_name, crossfade: wait
  sleep wait

  neo.start_recording scene_name
  sleep wait
end

neo.stop_recording

puts
puts 'Average times for scene update and render:'
neo.print_recordings
puts
puts 'Done'
puts
