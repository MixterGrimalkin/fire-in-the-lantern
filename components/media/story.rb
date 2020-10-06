require './components/assets'
require './lib/colours'

module Fitl
  class Story
    include Colours

    def initialize(size:, name: 'story', assets: Assets.new)
      @size = size
      @name = name
      @assets = assets
    end

    attr_reader :size, :assets
    attr_accessor :name

    def update

    end

    def render_over(base_layer)
      base_layer
    end
  end
end