class Master

  def start_loop
    loop do
      select_scene
      set_playlist
      set_lights
    end
  end

  def set_scene(scene_name)
    @scene = Scene.new(scene_name)
    set_playlist
    set_lights
  end

  def vlc_error
    @vlc_error ||= begin
      vlc
    rescue => error
      error.to_s
    else
      nil
    end
  end

  def hue_error
    @hue_error ||= begin
      hue
    rescue => error
      error.to_s
    else
      nil
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
    vlc.play
  end

  def set_lights
    puts "Setting Hue light config:"
    p scene.light_config
    hue.lights.each do |light|
      light.set_state(scene.light_config, LIGHT_TRANSITION_TIME)
    end
  end
end
