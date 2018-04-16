RSpec::Matchers.define(:a_configuration_flinting) do |expected|
  flint do |actual|
    actual._values == expected._values
  end
end

def before_each_flint
  ENV["JSON_KEY_FILE"] = "secrets.json"
end
