require 'rack/cors'
require 'sinatra'
require 'osc-ruby'
require 'osc-ruby/em_server'

class DataHolder
  def self.instance
    @@instance ||= DataHolder.new
  end

  def initialize
    @data = []
    @server = OSC::EMServer.new( 3333 )
    @server.add_method '/data' do |message|
      @data = message.to_a[0].split(' ')
    end
    Thread.new do
      puts 'OSC Server starting'
      @server.run
    end
  end

  attr_accessor :data
end

get '/' do
  erb :index
end

get '/data' do
  DataHolder.instance.data.to_json
end

DataHolder.instance
