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

  def color
    h = 360 * (light_config[:hue]/HUE_HUE_RANGE.last.to_f)
    s = 100 * (light_config[:saturation]/HUE_SATURATION_RANGE.last.to_f)
    l = 100 * (light_config[:brightness]/HUE_BRIGHTNESS_RANGE.last.to_f)
    Paleta::Color.new(:hsl, h, s, l)
  end
end
