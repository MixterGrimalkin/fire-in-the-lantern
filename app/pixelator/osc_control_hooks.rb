class OscControlHooks
  include Utils

  def initialize(pixelator, port: '3333', settings: OpenStruct.new)
    @settings = settings
    @pixelator, @port = pixelator, port
    @server_ip = local_ip_address

    attach_hook 'scene', :switch_scene
    attach_hook 'brightness', :change_brightness
    attach_hook 'stop', :stop
    attach_hook 'restart', :restart
    attach_hook 'reboot', :reboot
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

  def attach_hook(address, method)
    server.add_method "/#{address}" do |message|
      send(method, message)
    end
  end

  def from(message)
    "#{message.ip_address}:#{message.ip_port}"
  end

  def switch_scene(message)
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

  def change_brightness(message)
    if pixelator.neo_pixel.respond_to?(:brightness=)
      brightness = message.to_a[0].to_i
      pixelator.neo_pixel.brightness = brightness
      message "NeoPixel Brightness = #{brightness}"
    else
      message 'Brightness is not controllable'
    end
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
    if settings.allow_remote_reboot
      message '!!! Rebooting Pixelator Machine !!!'
      pixelator.clear
      `reboot`
    else
      message 'Remote rebooting is disabled'
    end
  end

  attr_reader :settings

end
