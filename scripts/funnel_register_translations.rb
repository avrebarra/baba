#!/usr/bin/env ruby

require "json"

def load_json(relative_path)
  file_path = File.expand_path(relative_path, __dir__)
  begin
    data = JSON.parse(File.read(file_path))
    return data
  rescue StandardError => e
    puts "Error loading JSON file: #{e.message}"
    return nil
  end
end

parsed_input = JSON.parse(ARGF.read)
translations = parsed_input["translations"]
translations.each_key do |key|
  file_path = File.expand_path("../assets/data/#{key}.dict.json", __dir__)

  dict = load_json(file_path)
  dict = {} if dict.nil?

  dict = dict.merge(translations[key]["keywords"])
  File.write(file_path, dict.to_json)
end

puts parsed_input.to_json
