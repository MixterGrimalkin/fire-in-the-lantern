require_relative 'factory'
require 'forwardable'

include Colors
include Utils
include Forwardable

def factory
  @factory ||= Factory.new
end
def_delegators :factory, :neo, :px

logo

if ARGV[0]
  px.load_scene ARGV[0]
  px.start

  message 'Press CTRL + C to make it stop'

  wait_for_interrupt

  px.clear
  px.stop
  neo.close
else
  message 'Specify a scene to load'
end

message 'Bye'
