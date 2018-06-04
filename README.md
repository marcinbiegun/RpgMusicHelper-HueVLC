# Rpg Music Helper for VLC and Philips Hue

This app allows to define scenes containing music files and a color.

The color is set on Philips Hue light bulbs. The music is played on VLC
player instance runnig in the background.

It's intended for RPG game master's use.

![Screenshot](https://raw.githubusercontent.com/marcinbiegun/RpgMusicHelper-HueVLC/master/docs/screenshot.png)

## Setup

Set colors and music:

1. Put your music in `scenes/SCENE_NAME` directories.
2. Set your color in `scenes/SCENE_NAME/hue.txt` set the scene color,
   the values are `hue,saturation,brigthness` and can be set `0,0,0` to `65535,255,255`.

Run VLC:

1. Run VLC with RemoteControl support: `/Applications/VLC.app/Contents/MacOS/VLC --extraintf rc --rc-host 127.0.0.1:9999`

Run the app:

1. Download shoes from: http://shoesrb.com/downloads/
2. Run `shoes.rb` files using Shoes.app

