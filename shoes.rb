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

APP_TITLE = "Rpg Music Helper"

HUE_HUE_RANGE = 0..65535
HUE_SATURATION_RANGE = 0..255
HUE_BRIGHTNESS_RANGE = 0..255

VLC_RC_IP = "127.0.0.1"
VLC_RC_PORT = 9999
SCENES_DIR = "scenes"
PROJECT_DIR = Dir.pwd
HUE_FILE = "hue.txt"
LIGHT_TRANSITION_TIME = 25 # * 0.1s

Shoes.app(title: APP_TITLE, width: 300, height: 400) do
  @master = Master.new
  @scene_buttons = []

  stack {
    Scene.all.each do |scene_name|
      flow {
        scene = Scene.new(scene_name)
        background scene.color_hex
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
        para "VLC: "
        @vlc_status = para "Connecting..."
      }
      flow {
        para "HUE: "
        @hue_status = para "Connecting..."
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
  if @master.vlc_error
    @vlc_status.text = @master.vlc_error
    @vlc_status.style(stroke: red)
  else
    @vlc_status.text = "Connected"
    @vlc_status.style(stroke: green)
  end
  if @master.hue_error
    @hue_status.text = @master.hue_error
    @hue_status.style(stroke: red)
  else
    @hue_status.text = "Connected"
    @hue_status.style(stroke: green)
  end
end
