require 'osc-ruby'

target_ip = '192.168.0.34'
target_port = '3333'
target_address = ARGV[0] || 'scene'
target_data = ARGV[1] || 'day'

OSC::Client.new(target_ip, target_port)
    .send OSC::Message.new("/#{target_address}", target_data)
