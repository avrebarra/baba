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

def get_next_id
  existing_ids = Dir.glob('./_contents/*.md').map { |file| File.basename(file).split('-')[0].to_i }
  current_id = (existing_ids.max || 0) + 1
  current_id.to_s.rjust(8, '0')
end

def kebab_case(title)
  title.downcase.gsub(' ', '-')
end

parsed_input = JSON.parse(ARGF.read)

title = parsed_input['title']
moral = parsed_input['moral']
keywords = parsed_input['keywords']
paragraphs = parsed_input['paragraphs']
hook = parsed_input['hook']
translations = parsed_input['translations']

id = get_next_id
filename = "./_contents/#{id}-#{kebab_case(title)}"
file_content = <<~MD
---
layout: story
title: #{title}
hook: #{hook}
moral: #{moral}
keywords: #{keywords}
---

#{paragraphs.join("\n\n")}
MD

# update dictionary
PATH_DICTIONARY = file_path = File.expand_path("../assets/data/dict.json", __dir__)
dict = load_json(PATH_DICTIONARY)
dict = dict.merge(translations)

File.write(filename+".md", file_content)
File.write(filename+".json", parsed_input.to_json)
File.write(PATH_DICTIONARY, dict.to_json)
