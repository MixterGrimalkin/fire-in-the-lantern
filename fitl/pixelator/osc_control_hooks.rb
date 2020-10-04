class OscControlHooks
  include Utils

  def initialize(pixelator, port: '3333', assets: Assets.new)
    @pixelator, @port = pixelator, port
    @server_ip = local_ip_address
    @assets = assets

    attach_hook :scene
    attach_hook :brightness
    attach_hook :clear
    attach_hook :stop
    attach_hook :restart
    attach_hook :reboot
  end

  attr_reader :pixelator, :server_ip, :port

  def start
    Thread.new do
      server.run
    end
    message "OSC Control Hooks @ #{server_ip}:#{port}"
  end

  private

  def server
    @server ||= OSC::EMServer.new port
  end

  def attach_hook(address)
    server.add_method "/#{address.to_s}" do |message|
      send(address, message)
    end
  end

  def scene(message)
    scene_name, crossfade = *scene_params(message)
    pixelator.load_scene scene_name, crossfade: crossfade
    message "Loaded Scene: #{scene_name} (from #{from(message)})"
  rescue Errno::ENOENT
    message "Sorry bud, I don't know how to #{scene_name}"
  end

  def scene_params(message)
    parts = message.to_a[0].split(' ')
    [parts[0], parts[1]&.to_i || pixelator.default_crossfade]
  end

  def from(message)
    "#{message.ip_address}:#{message.ip_port}"
  end

  def brightness(message)
    if pixelator.neo_pixel.respond_to?(:brightness=)
      brightness = message.to_a[0].to_i
      pixelator.neo_pixel.brightness = brightness
      message "NeoPixel Brightness = #{brightness}"
    else
      message 'Brightness is not controllable'
    end
  end

  def clear(_message)
    message 'Clearing Pixelator'
    pixelator.clear
  end

  def stop(_message)
    message 'Stopping Pixelator'
    pixelator.clear
    exit 0
  end

  def restart(_message)
    message 'Restarting Pixelator'
    pixelator.clear
    exit 9
  end

  def reboot(_message)
    if assets.settings.allow_remote_reboot
      message '!!! Rebooting Pixelator Machine !!!'
      pixelator.clear
      `reboot`
    else
      message 'Remote rebooting is disabled'
    end
  end

  attr_reader :assets

end
