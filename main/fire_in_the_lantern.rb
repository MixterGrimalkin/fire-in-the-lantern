FITL = %{
    ___
   (_  '_ _   '  _// _   /  _  _/_ _
   /  // (-  //) //)(-  (__(//)/(-/ /)

       p  i  x  e  l  a  t  o  r


}

require './main/requirer'

module FireInTheLantern
  def self.included(base)
    base.class_eval do
      include Fitl
      include Colours
      include Utils
      include Forwardable
      def_delegators :factory,
                     :neo, :px, :osc, :clear, :settings,
                     :layer, :cue, :scene, :story
      puts FITL
    end
  end

  def factory(adapter_override: nil, disable_osc_hooks: false)
    @factory ||= Factory.new(
        filename: config_filename,
        adapter_override: adapter_override,
        disable_osc_hooks: disable_osc_hooks
    )
  end

  def config_filename
    ENV['FITL_CONFIG'] || Factory::DEFAULT_CONFIG_FILE
  end
end
