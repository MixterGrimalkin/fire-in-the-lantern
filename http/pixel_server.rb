require_relative 'neo_pixel'
require 'sinatra'

class DataHolder
  def self.instance
    @@instance ||= DataHolder.new
  end
  def initialize
    @data = []
  end
  attr_accessor :data
end

post '/data' do
  DataHolder.instance.data = JSON.parse(params[:data])
  200
end

get '/data' do
  DataHolder.instance.data.to_json
end
