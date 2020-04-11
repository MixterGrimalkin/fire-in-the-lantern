require_relative '../pixelator/pixelator'

require_relative '../neo_pixel/neo_pixel'
require_relative '../neo_pixel/ws_neo_pixel'
require_relative '../neo_pixel/osc_neo_pixel'
require_relative '../neo_pixel/http_neo_pixel'
require_relative '../neo_pixel/text_neo_pixel'

require_relative '../lib/color'
require_relative '../lib/color_a'
require_relative '../lib/color_tools'
require_relative '../lib/utils'

require_relative 'factory'

require 'forwardable'
require 'json'

module FireInTheLantern

  def self.included(base)
    base.class_eval do
      include Colors
      include Utils
      include Forwardable
      def_delegators :factory, :neo, :px, :scn, :clear
      logo
    end
  end

  def factory
    @factory ||= Factory.new
  end

end
