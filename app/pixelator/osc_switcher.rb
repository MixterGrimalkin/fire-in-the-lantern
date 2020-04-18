class OscSwitcher
  include Utils

  def initialize(pixelator, port: '3333', address: 'scene')
    @pixelator = pixelator
    @server_port = port
    @osc_address = address

    @server_ip = local_ip_address
    @server = OSC::EMServer.new server_port

    server.add_method "/#{osc_address}" do |message|
      on_receive message
    end
  end

  def start
    message "OSC Scene Switcher on: #{server_ip}:#{server_port}/#{osc_address}"
    Thread.new do
      server.run
    end
  end

  def on_receive(message)
    first_args = message.to_a[0].split(' ')
    scene_name = first_args[0]
    if (crossfade = first_args[1])
      pixelator.load_scene scene_name, crossfade: crossfade.to_i
    else
      pixelator.load_scene scene_name
    end
    message "Loaded Scene: #{scene_name} (from #{message.ip_address}:#{message.ip_port})"
  rescue Errno::ENOENT
    message "Sorry bud, I don't know how to #{scene_name}"
  end

  attr_reader :pixelator, :server, :server_ip, :server_port, :osc_address
end
