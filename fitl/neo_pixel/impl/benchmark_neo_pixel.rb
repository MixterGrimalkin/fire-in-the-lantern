require_relative '../neo_pixel'

require_relative '../../lib/utils'

class BenchmarkNeoPixel < NeoPixel
  include Utils

  def initialize(pixel_count:, mode:)
    super(pixel_count: pixel_count, mode: mode)
    @recordings = {}
    @current_recording = nil
  end

  def start_recording(name)
    puts "Recording #{name}"
    @current_recording = recordings[name] = []
  end

  def stop_recording
    @current_recording = nil
  end

  def show(buffer)
    if current_recording
      current_recording << Time.now
    end
  end

  def print_recordings
    data = recordings.collect do |name, data|
      if data.empty?
        [name, nil]
      else
        start = data[0]
        sum = 0.0
        data[1..-1].each do |show|
          sum += (show - start)
          start = show
        end
        avg = sum / (data.size - 1)
        [name, "#{(avg*1000).floor}ms   #{(1.0/avg).floor}fps"]
      end
    end
    print_table data
  end

  private

  attr_reader :current_recording, :recordings

end
