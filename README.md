# Fire in the Lantern

A Pixelator for driving WS281x (NeoPixel) LED fixtures with a Raspberry Pi.

The software has three operating modes: **Scene Loader**, **Interactive Session**,
and **Direct OSC Control**. These are detailed below. 


## Installation

I haven't packaged this up nicely yet, so to install this software on a Raspberry Pi
you will need to either clone this repo directly onto the Pi, or clone it to another
machine and run the `deploy.sh` script to upload the contents of the `/fitl` 
directory to `/home/pi/fitl` on the target Pi. 
This script reads the target IP address from the `.pi` file in the repo root, and will 
create the target directory if it doesn't exist.

The latter is preferable, unless you particularly want to run the `rspec`
tests on the Pi itself, which probably isn't necessary.

In either case, move to the `/home/pi/fitl` 
(or `wherever-you-cloned-it/fire-in-the-lantern/fitl`) directory and run one of the 
Bash scripts there to start the software in the various modes.

**Note:** You will almost certainly go through a minor Dependency Nightmare to get
things running (especially since the scripts must be run as root, which means
`bundle install` isn't necessarily your friend) and I will almost certainly, 
eventually, get round to detailing here all the steps you need to follow.


## Wiring

The NeoPixel can't be powered from the Pi's header, so you'll need to power it up
separately (check your precise type of NeoPixel to see what voltage you need). 
You need to connect the ground leg of your DC power supply to one of the GND pins 
on the Pi's header, because reasons.

Then connect the DATA IN of your fixture to GPIO 18 (PWM) on the Pi's header.


## Configuration

The software keeps its configuration in a file called `.fitl.json` which lives in the
repo root (or `/home/pi` if you used `deploy.sh`). This file will be created with
probably-sensible defaults if it doesn't exist.

Key settings are:

- `Adapter` - The class used to drive the display. For basic use on a Raspberry 
Pi this should be `WsNeoPixel`. If you're driving another instance of FITL 
over a network then use `OscNeoPixel`.

- `Pixelator` - Settings for the Pixelator.
    - `frame_rate` - Intended (and maximum) frames per second.
     The actual frame rate may be less than this,
     depending on how complex the scene you're running is.
    - `osc_control_port` - If set (and not `null`) an OSC server
    will run on this port in Scene Loader mode to allow basic remote control
    of the Pixelator while it is running.
    
- `NeoPixel` - General settings for the display adapter. 
    - `pixel_count` - Number of physical pixels in your fixture.
    - `mode` - Color conversion mode used when rendering to the fixture - can be `rgb`,
    `grb` or `rgbw`.
    
- There are configuration sections that let you customize each 
of the concrete NeoPixel classes.

- `DirectOscServer` - OSC port and address to use for Direct OSC Control
 mode.
 
- `Settings` - Some general settings.
 
### Quick Test

To perform a simple test of the fixture, run:

```
sudo ./test.sh
```

This will turn all pixels RED, GREEN, BLUE, WARM_WHITE (if `mode` is `rgbw`) and then 
FULL_WHITE. If you provide an argument to the script, this will be interpreted as the time
(in seconds) to show each color. Default is 1.


## Modes

### Scene Loader

This mode loads a scene from a .json file and runs it. If OSC Control is enabled,
the Pixelator will respond to remote OSC commands to switch scene, control NeoPixel
brightness, and stop or restart the software on the host machine.

Start FITL off in this mode with:

```
sudo ./load.sh [scene_name]
```

The software will look for a file called `[scene_name].json` in the `scenes_dir` specified
in the configuration file. The default is `scenes`.

If you don't provide a Scene name the software will load the `default_scene` specified
in the configuration file.

If you have specified an `osc_control_port` in the configuration file then an OSC server 
will start on that port to allow basic remote control. Simply send an OSC command to that 
port on the Pi, with any of the following addresses and arguments:

- `/scene <scene_name>` Loads a scene, with the default crossfade time.
- `/brightness <b>` Sets NeoPixel brightness (0..255)
- `/stop` Exits FITL
- `/restart` Exits and then restarts FITL
- `/reboot` Reboots the target machine (must be enabled with the `allow_remote_reboot`
option in the configuration file - defaults to `false` for obvious reasons)

### Interactive Session

This mode opens an `irb` session pre-loaded with the FITL classes.

Start it off in this mode with:

```
sudo ./session.sh [-init]
```

You are provided with several methods to access the parts of the software:

- `init` Starts the Pixelator (called automatically if you provide the `-init` flag)
- `factory` Returns the Factory used to build the software components
- `px` Returns the Pixelator
- `neo` Returns the NeoPixel adapter
- `osc` Returns the Direct OSC Control mode server
- `scn` Returns the Scene currently running on the Pixelator
- `layers` Prints a list of the Layers in the current Scene
- `scenes` Provides a simple text menu to load available Scenes
- `settings` Returns an `OpenStruct` with the values from the `Settings` section of
the configuration file

An example session might look like this:

```
pi@rasp69:~/fire-lanterns$ sudo ./session.sh -init

    ___
   (_  '_ _   '  _// _   /  _  _/_ _
   /  // (-  //) //)(-  (__(//)/(-/ /)

       p  i  x  e  l  a  t  o  r

   px = #<Pixelator[WsNeoPixel] pixels:35 layers:1 STARTED>

>> px.load_scene 'swirls'
=> "Loaded swirls"
>> layers
base  #<Layer(35/35)⭘  α=1.0 δl=x1 δp=x1>      
a     #<Layer(35/100)⭘  α=1.0 δl=x1 δp=0.08x6> 
b     #<Layer(11/100)⭘  α=0.5 δl=-0.05x6 δp=x1>
c     #<Layer(35/100)⭘  α=0.6 δl=x1 δp=-0.07x6>
=> 4
>> scn.a.hide
=> false
>> layers
base  #<Layer(35/35)⭘  α=1.0 δl=x1 δp=x1>      
a     #<Layer(35/100)⭙  α=1.0 δl=x1 δp=0.08x6> 
b     #<Layer(11/100)⭘  α=0.5 δl=-0.05x6 δp=x1>
c     #<Layer(35/100)⭘  α=0.6 δl=x1 δp=-0.07x6>
=> 4
>> 
```

Press `CTRL` + `D` to exit.

### Direct OSC Control

This mode starts the NeoPixel adapter but not the Pixelator, and allows the fixture to be
rendered directly via a single OSC command. This is useful if you want to run the Pixelator on one machine
to control the NeoPixel fixture attached to another.

Start FITL in this mode with:

```
sudo ./osc.sh
```

Then on the controlling machine, set your `Adapter` to `OscNeoPixel` and change the relevant
settings section to point at your Pi. You can run the controlling instance of FITL in Scene Loader
or Interactive Session mode.

## Software API

Yeah, I'll get round to documenting this when it's finished ;)

## Acknowledgements

Made possible with the WS2812 Ruby gem by **Michal J**, which you can find here: https://github.com/wejn/ws2812
 


