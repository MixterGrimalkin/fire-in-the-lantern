require_relative '../main/fire_in_the_lantern'

include FireInTheLantern

factory disable_osc_hooks: true

def init
  px.start
  puts "   px = #{px.inspect}\n\n"
end

if (options = ENV['OPTIONS'])
  init if options.include?('-init')
end
