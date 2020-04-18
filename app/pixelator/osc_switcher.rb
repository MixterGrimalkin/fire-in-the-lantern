class OscSwitcher

  def initialize(pixelator, port: '3333', address: 'scene')
    @pixelator = pixelator
    @server_port = port
    @osc_address = address

    @server_ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
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
    scene_name = message.to_a[0]
    message "#{message.ip_address}:#{message.ip_port} requests '#{scene_name}'"
    pixelator.load_scene scene_name
  rescue Errno::ENOENT
    message 'Scene not found!'
  end

  attr_reader :pixelator, :server, :server_ip, :server_port, :osc_address

end