require_relative '../spec_helper'

include Colors

RSpec.describe TextNeoPixel do

  let(:neo_pixel) { TextNeoPixel.new pixel_count: 4 }

  it 'renders' do
    expect { neo_pixel.render }
        .to output("\r[#{black}#{black}#{black}#{black}]")
                .to_stdout

    neo_pixel[1] = Color.new(80)
    neo_pixel[2] = Color.new(180)
    neo_pixel[3] = Color.new(255)
    expect { neo_pixel.render }
        .to output("\r[#{black}#{grey}#{white}#{white}]")
                .to_stdout

    expect { neo_pixel.on }
        .to output("\r[#{white}#{white}#{white}#{white}]")
                .to_stdout

    expect { neo_pixel.on RED }
        .to output("\r[#{red}#{red}#{red}#{red}]")
                .to_stdout

    expect { neo_pixel.off }
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
