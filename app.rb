require 'io/console'
require 'vlc-client'
require 'hue'
require 'pry'

# /Applications/VLC.app/Contents/MacOS/VLC --extraintf rc --rc-host 192.168.1.111:9999

VLC_RC_IP = "127.0.0.1"
VLC_RC_PORT = 9999
SCENES_DIR = "scenes"
PROJECT_DIR = Dir.pwd
HUE_FILE = "hue.txt"
LIGHT_TRANSITION_TIME = 25 # * 0.1s

class Scene
  attr_reader :name

  def self.all
    scenes = []
    Dir.foreach(SCENES_DIR) do |item|
      next if [".", ".."].include?(item)
      next unless File.directory?("#{SCENES_DIR}/#{item}")
      scenes << item
    end
    scenes
  end

  def initialize(name)
    @name = name
    raise "Scene directory '#{name}' not found" unless File.directory?(relative_path)
  end

  def relative_path
    "#{SCENES_DIR}/#{name}"
  end

  def absolute_path
    "#{PROJECT_DIR}/#{SCENES_DIR}/#{name}"
  end

  def audio_absolute_paths
    paths = []
    Dir.foreach(relative_path) do |item|
      next if [".", ".."].include?(item)
      next unless item.include?(".mp3")
      paths << "#{absolute_path}/#{item}"
    end
    paths
  end

  def light_config
    values = File.open("#{relative_path}/#{HUE_FILE}").read.split(",")
    {
      :hue => values[0].to_i,
      :saturation => values[1].to_i,
      :brightness => values[2].to_i
    }
  end
end

class Master
  def initialize
    vlc && hue # init connections
  end

  def start_loop
    loop do
      select_scene
      set_playlist
      set_lights
    end
  end

  private
  attr_reader :scene

  def vlc
    @vlc ||= begin
      client = VLC::Client.new(VLC_RC_IP, VLC_RC_PORT)
      client.connect
      client
    end
  end

  def hue
    @hue ||= Hue::Client.new
  end

  def select_scene
    scenes = Scene.all

    puts "\nSelect scene:"
    scenes.each_with_index do |scene, i|
      puts "#{i+1}) #{scene}"
    end

    input = STDIN.getch
    name = scenes[input.to_i-1]
    puts "Selectd: #{name}"
    @scene = Scene.new(name)
  end

  def set_playlist
    puts "Clearing playlist"
    vlc.clear

    scene.audio_absolute_paths.shuffle.each do |audio_path|
      puts "Adding to playlist #{audio_path}"
      vlc.add_to_playlist(audio_path)
    end

    puts "Play!"
    vlc.next
  end

  def set_lights
    puts "Setting Hue light config:"
    p scene.light_config
    hue.lights.each do |light|
      light.set_state(scene.light_config, LIGHT_TRANSITION_TIME)
    end
  end
end

Master.new.start_loop
