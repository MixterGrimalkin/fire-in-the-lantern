require './components/neopixel/console_neopixel'

include Fitl
include Colours

RSpec.describe Fitl::ConsoleNeopixel do

  let(:neo) { described_class.new pixel_count: 4 }

  it 'renders' do
    expect { neo.render }
        .to output("\r[#{black}#{black}#{black}#{black}]")
                .to_stdout

    neo[1] = Colour.new(80)
    neo[2] = Colour.new(180)
    neo[3] = Colour.new(255)
    expect { neo.render }
        .to output("\r[#{black}#{grey}#{white}#{white}]")
                .to_stdout

    expect { neo.on }
        .to output("\r[#{white}#{white}#{white}#{white}]")
                .to_stdout

    expect { neo.on RED }
        .to output("\r[#{red}#{red}#{red}#{red}]")
                .to_stdout

    expect { neo.off }
        .to output("\r[#{black}#{black}#{black}#{black}]")
                .to_stdout
  end

  let(:black) { pix(0, 2, 30) }
  let(:grey) { pix(0, 2, '1;37') }
  let(:white) { pix(0, 1, '1;37') }
  let(:red) { pix(0, 1, 31) }

  def pix(bg, fo, fg)
    "\e[#{bg};#{fo};#{fg}m■\e[0m"
  end
end
