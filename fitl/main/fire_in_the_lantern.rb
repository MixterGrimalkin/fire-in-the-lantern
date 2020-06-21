require_relative '../pixelator/pixelator'
require_relative '../pixelator/envelope'
require_relative '../pixelator/osc_control_hooks'

require_relative '../neo_pixel/direct_osc_server'
require_relative '../neo_pixel/neo_pixel'

require_relative '../neo_pixel/impl/ws_neo_pixel'
require_relative '../neo_pixel/impl/osc_neo_pixel'
require_relative '../neo_pixel/impl/http_neo_pixel'
require_relative '../neo_pixel/impl/text_neo_pixel'
require_relative '../neo_pixel/impl/benchmark_neo_pixel'

require_relative '../color/tools'
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
      def_delegators :factory, :neo, :px, :osc, :clear, :settings
      logo
    end
  end

  def factory(filename: '../.fitl.json', adapter_override: nil, disable_osc_hooks: false)
    @factory ||= Factory.new(
        filename: filename,
        adapter_override: adapter_override,
        disable_osc_hooks: disable_osc_hooks
    )
  end

end
