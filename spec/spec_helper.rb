%w(color lib neo_pixel neo_pixel/impl pixelator).each do |dir|
  Dir.glob("#{dir}/*.rb").each do |filename|
    require "./#{filename}"
  end
end

require 'forwardable'
require 'json'

require './fitl/main/factory'
