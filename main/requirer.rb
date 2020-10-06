REQUIRE_DIRECTORIES = %w(
  components
  components/media
  components/modifiers
  components/neopixel
  components/osc
  lib
)

REQUIRE_DIRECTORIES.each do |dir|
  Dir.glob("#{dir}/*.rb").each do |filename|
    require "./#{filename}"
  end
end

require 'forwardable'
require 'json'

