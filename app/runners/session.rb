require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

def init
  px.start
  puts "   px = #{px.inspect}\n\n"
end

def layers
  print_table scn.layers.collect { |k, l| [k, l.inspect] }
  scn.layers.size
end

def scenes(crossfade = px.default_crossfade)
  scene = pick_from(
      Dir.glob("#{px.scenes_dir}/*.json").collect do |filename|
        filename.split('/')[-1].gsub('.json', '')
      end
  )
  px.load_scene(scene, crossfade: crossfade) if scene
end

if (options = ENV['OPTIONS'])
  init if options.include?('-init')
end
