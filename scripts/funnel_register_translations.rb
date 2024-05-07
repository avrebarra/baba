require 'json'

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
translations = parsed_input['translations']

# update dictionary
PATH_DICTIONARY = file_path = File.expand_path("../assets/data/dict.json", __dir__)
dict = load_json(PATH_DICTIONARY)
dict = dict.merge(translations)

File.write(PATH_DICTIONARY, dict.to_json)

puts parsed_input.to_json
