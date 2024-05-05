require 'json'

def get_next_id
  existing_ids = Dir.glob('./_contents/*.md').map { |file| File.basename(file).split('-')[0].to_i }
  current_id = (existing_ids.max || 0) + 1
  current_id.to_s.rjust(8, '0')
end

def kebab_case(title)
  title.downcase.gsub(/[^0-9a-z ]/, '').gsub(' ', '-')
end

output = JSON.parse(ARGF.read)

title = output['title']
moral = output['moral']
keywords = output['keywords']
paragraphs = output['paragraphs']
hook = output['hook']


id = get_next_id
filename = "./_contents/#{id}-#{kebab_case(title)}.md"
file_content = <<~MD
---
title: #{title}
hook: #{hook}
moral: #{moral}
keywords: #{keywords}
---

#{paragraphs.join("\n\n")}
MD

File.write(filename, file_content)
