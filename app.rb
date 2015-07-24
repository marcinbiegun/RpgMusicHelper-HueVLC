require 'io/console'
require 'vlc-client'
require 'pry'

IP = "192.168.1.111"
PORT = 9999
SCENES_DIR = "scenes"
PROJECT_DIR = Dir.pwd



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
end



scenes = Scene.all
puts "Select scene:"
scenes.each_with_index do |scene, i|
  puts "#{i+1}) #{scene}"
end

input = STDIN.getch
name = scenes[input.to_i-1]
scene = Scene.new(name)

vlc = VLC::Client.new(IP, PORT)
vlc.connect
vlc.clear

scene.audio_absolute_paths.shuffle.each do |audio_path|
  puts "Adding to playlist: #{audio_path}"
  vlc.add_to_playlist(audio_path)
end

vlc.next
