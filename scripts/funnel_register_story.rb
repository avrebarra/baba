require 'json'

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

File.write(filename+".md", file_content)
File.write(filename+".json", parsed_input.to_json)

puts parsed_input.to_json
