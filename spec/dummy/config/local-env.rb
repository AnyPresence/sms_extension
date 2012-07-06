local_env = YAML.load_file(File.expand_path("../local-env.yml", __FILE__)) rescue nil

if local_env
  local_env.each_pair do |key, value|
    ENV[key] ||= value
  end
end