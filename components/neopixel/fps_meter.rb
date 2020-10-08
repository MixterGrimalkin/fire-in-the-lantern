require './lib/utils'

module Fitl
  class FpsMeter
    include Utils

    def initialize(target_fps)
      @target_fps = target_fps
      @time_buffer = []
      @update_period = 1
      @running = false
      @last_render = nil
      @last_update = Time.now
    end

    attr_reader :target_fps, :update_period
    attr_accessor :time_buffer, :last_render, :last_update, :running

    def run
      self.running = true

      while true
        update
        sleep 0.5
      end

    rescue IRB::Abort
      self.running = false
    end

    METER_WIDTH = 60

    def update
      return unless running && (Time.now - last_update) >= update_period
      fps = average_fps
      amount = fps / target_fps
      print "\r[#{meter(amount)}] #{'%.2f' % fps} "
      self.last_update = Time.now
    end

    def meter(amount)
      if amount > 0.0
        bottom_quarter(amount) + middle_half(amount) + top_quarter(amount)
      else
        colorize('■' * METER_WIDTH, :black)
      end
    end

    def bottom_quarter(amount)
      if amount > 0.25
        colorize('■' * (METER_WIDTH / 4), :red)
      else
        red_count = (amount * METER_WIDTH).to_i
        black_count = ((METER_WIDTH / 4) - red_count).to_i
        colorize('■' * red_count, :red) + colorize('■' * black_count, :black)
      end
    end

    def middle_half(amount)
      if amount < 0.25
        colorize('■' * (METER_WIDTH / 2), :black)
      elsif amount > 0.75
        colorize('■' * (METER_WIDTH / 2), :yellow)
      else
        yellow_count = ((amount * METER_WIDTH) - (METER_WIDTH / 4)).to_i
        black_count = ((METER_WIDTH / 2) - yellow_count).to_i
        colorize('■' * yellow_count, :yellow) + colorize('■' * black_count, :black)
      end
    end

    def top_quarter(amount)
      if amount < 0.75
        colorize('■' * (METER_WIDTH / 4), :black)
      else
        green_count = ((amount * METER_WIDTH) - (3 * METER_WIDTH / 4)).to_i
        black_count = ((METER_WIDTH / 4) - green_count).to_i
        colorize('■' * green_count, :green) + colorize('■' * black_count, :black)
      end
    end

    def log_render
      return unless running

      if last_render
        time_buffer << (Time.now - last_render)
      end
      self.last_render = Time.now
    end

    def average_fps
      avg = 1 / (time_buffer.sum.to_f / time_buffer.size)
      self.time_buffer = []
      avg
    end
  end
end