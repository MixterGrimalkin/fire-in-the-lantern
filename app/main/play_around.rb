require_relative 'factory'
require 'forwardable'

include Colors
include Utils
include Forwardable

def factory
  @factory ||= Factory.new
end
def_delegators :factory, :neo, :px, :scn, :clear

logo

def layers
  max_width = 0
  scn.layers.each do |key, _|
    max_width = [max_width, key.to_s.length].max
  end
  scn.layers.each do |key, layer|
    puts "#{key.to_s.ljust(max_width)} : #{layer.inspect}"
  end
  nil
end

if (options = ENV['OPTIONS'])
  if options.include?('-init')
    px.start
    puts "   px = #{px.inspect}\n\n"
  end
end
