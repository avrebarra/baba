require 'json'

contents = ARGF.read

def parse_markdown(contents)
  data = {}
  data_arr = contents.split("---")[1].strip.split("\n").map { |line| line.split(":").map(&:strip) }
  
  paragraphs = contents.split("---")[2].strip.split("\n").map(&:strip).reject(&:empty?)
  
  data_arr.each do |key, value|
    if key == "keywords"
      data[key] = value.tr('[]",', '').split
    else
      data[key] = value
    end
  end
  
  data["paragraphs"] = paragraphs

  data
end

def markdown_to_json(contents)
  markdown_data = parse_markdown(contents)
  json_data = {
    "title" => markdown_data["title"],
    "hook" => markdown_data["hook"],
    "paragraphs" => markdown_data["paragraphs"],
    "moral" => markdown_data["moral"],
    "keywords" => markdown_data["keywords"]
  }

  json_data.to_json
end

puts markdown_to_json(contents)
