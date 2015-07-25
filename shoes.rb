Shoes.setup do
  gem 'vlc-client'
  gem 'hue'
end

require 'vlc-client'
require 'hue'

require_relative './lib/scene.rb'
require_relative './lib/master.rb'

# /Applications/VLC.app/Contents/MacOS/VLC --extraintf rc --rc-host 192.168.1.111:9999

VLC_RC_IP = "127.0.0.1"
VLC_RC_PORT = 9999
SCENES_DIR = "scenes"
PROJECT_DIR = Dir.pwd
HUE_FILE = "hue.txt"
LIGHT_TRANSITION_TIME = 25 # * 0.1s

Shoes.app(width: 300, height: 400) do
  @master = Master.new
  stack {
    Scene.all.each do |scene_name|
      flow {
        oval(top: 5, left: 5, radius: 10)
        b = button(scene_name.capitalize)
        b.style(margin_left: 30)
        b.instance_variable_set(:@scene_name, scene_name)
        b.click do |x|
          @master.set_scene(x.instance_variable_get(:@scene_name))
          x.style(underline: "single")
        end
      }
    end

    flow(margin_top: 50) {
      para "VLC "
      @vlc_status = edit_line
      @vlc_status.text = "Connecting..."
      @vlc_status.style(state: "disabled")
    }

    flow {
      para "HUE "
      @hue_status = edit_line
      @hue_status.text = "Connecting..."
      @hue_status.style(state: "disabled")
    }
  }
end
