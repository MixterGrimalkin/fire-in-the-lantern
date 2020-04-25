pixel_zone candles: [0, 1, 15, 16, 20, 21, 40, 51, 52]
pixel_zone lanterns: [2, 3, 4, 17, 18, 19, 22, 23, 23, 38, 39, 41, 42, 53, 54, 55]
pixel_zone creepers: zone.all - zone.candles - zone.lanterns

scene_group basic: %w(candle_wheel candle_pulse butterflies)
scene_group special: %w(five_elements polyflies close_encounters)

story do
  play_scene basic.next, max_time: 6000
  play_scene basic.next, max_time: 6000
  play_scene special.random, max_time: 60
end

####

layer(:a, canvas: zone.all, background: RED).opacity = 0

repeat do
  cue time: 4 do
    every 1 do
      a.opacity = rand * 0.3
    end
  end
  cue time: 4 do
    a.fill BLUE
    every 0.75, chance: 0.8 do
      a.opacity = 0.4 + rand * 0.3
    end
  end
  cue time: 2 do
    a.fill ORANGE
    a.opacity = 1
  end
  cue name: 'swirls', time: 1
  cue time: 4 do
    a.fade_out 3
  end
end

