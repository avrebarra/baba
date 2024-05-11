#!/usr/bin/env ruby

require "json"

def get_next_id
  existing_ids =
    Dir
      .glob("./_contents/*.md")
      .map { |file| File.basename(file).split("-")[0].to_i }
  current_id = (existing_ids.max || 0) + 1
  current_id.to_s.rjust(4, "0")
end

def kebab_case(title)
  title.downcase.gsub(" ", "-")
end

parsed_input = JSON.parse(ARGF.read)

title = parsed_input["title"]
hook = parsed_input["hook"]
moral = parsed_input["moral"]
paragraphs = parsed_input["paragraphs"]
keywords = parsed_input["keywords"]
characters = parsed_input["characters"]

id = get_next_id
filename = "./_contents/#{id}-#{kebab_case(title)}"
file_content = <<~MD
---
layout: story
title: #{title}
hook: #{hook}
moral: #{moral}
characters: #{characters}
keywords: #{keywords}
---

#{paragraphs.join("\n\n")}
MD

File.write(filename + ".md", file_content)
File.write(filename + ".json", parsed_input.to_json)

puts parsed_input.to_json
