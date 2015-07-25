Shoes.setup do
  gem 'vlc-client'
  gem 'hue'
  gem 'paleta'
end

require 'vlc-client'
require 'hue'
require 'paleta'

require_relative './lib/scene.rb'
require_relative './lib/master.rb'

# /Applications/VLC.app/Contents/MacOS/VLC --extraintf rc --rc-host 192.168.1.111:9999
#
# hue.txt format is: "hue,saturation,brightness"

HUE_HUE_RANGE = 0..65535
HUE_SATURATION_RANGE = 0..255
HUE_BRIGHTNESS_RANGE = 0..255

VLC_RC_IP = "127.0.0.1"
VLC_RC_PORT = 9999
SCENES_DIR = "scenes"
PROJECT_DIR = Dir.pwd
HUE_FILE = "hue.txt"
LIGHT_TRANSITION_TIME = 25 # * 0.1s

Shoes.app(width: 300, height: 400) do
  @master = Master.new
  @scene_buttons = []

  stack {
    Scene.all.each do |scene_name|
      flow {
        scene = Scene.new(scene_name)
        oval(top: 5, left: 5, radius: 10, fill: "##{scene.color.hex}")
        butt = button(scene_name.capitalize)
        butt.style(margin_left: 30)
        butt.instance_variable_set(:@scene_name, scene_name)
        para "#{scene.audio_absolute_paths.count} songs"
        @scene_buttons << butt
      }
    end

    stack(margin_top: 50) {
      para "Connections status:"
      flow {
        para "VLC "
        @vlc_status = edit_line
        @vlc_status.text = "Connecting..."
      }
      flow {
        para "HUE "
        @hue_status = edit_line
        @hue_status.text = "Connecting..."
      }
    }
  }

  # Buttons for changing scene
  @scene_buttons.each do |scene_button|
    scene_button.click do |butt|
      @master.set_scene(butt.instance_variable_get(:@scene_name))
    end
  end

  # Check connections
  @vlc_status.text = @master.vlc_error || "OK"
  @hue_status.text = @master.hue_error || "OK"
end
