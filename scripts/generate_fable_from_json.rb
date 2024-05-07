require 'json'

contents = JSON.parse(ARGF.read)

def reformat_json(contents)
  json_data = {
    "title" => contents["title"],
    "hook" => contents["hook"],
    "moral" => contents["moral"],
    "paragraphs" => contents["paragraphs"],
    "keywords" => contents["keywords"],
    "translations" => {}
  }
  
  json_data.to_json
end

puts reformat_json(contents)
