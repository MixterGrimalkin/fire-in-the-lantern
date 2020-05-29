require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

factory disable_osc_hooks: true

def init
  px.start
  puts "   px = #{px.inspect}\n\n"
end

# def layers
#   print_table scn.layers.collect { |k, l| [k, l.inspect] }
#   scn.layers.size
# end

# def scenes(crossfade = px.default_crossfade)
#   scene = text_menu(
#       Dir.glob("#{px.scenes_dir}/*.json").collect do |filename|
#         filename.split('/')[-1].gsub('.json', '')
#       end,
#       'Scene'
#   )
#   px.load_scene(scene, crossfade: crossfade) if scene
# end

if (options = ENV['OPTIONS'])
  init if options.include?('-init')
end
