require 'json'
require 'net/http'
require 'uri'
require 'securerandom'
require 'optparse'

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

def generate_translations(words, from_language, to_language)
    api_key = ENV['OPENAI_API_KEY']
    raise "OpenAI API key not found in environment variables." if api_key.nil?

    uri = URI('https://api.openai.com/v1/chat/completions')
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
        {
            "role": "system",
            "content": "You work on company generating daily mature fables to learn foreign language. Compact answer in requested format."
        },
        {
            "role": "user",
            "content": "Generate literal translations for below words. Can be multiple words for common synonyms.\nWords: ['#{words.join("','")}']\nFrom: #{from_language}\nTo: #{to_language}\nFormat: JSON Map<string, string[]> (keyword to translations)"
        }
        ],
        "temperature": 1,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
    }

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{api_key}"
    req.body = data.to_json

    puts api_key
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
    end

    if response.is_a?(Net::HTTPSuccess)
        result = JSON.parse(response.body)
        return result['choices'][0]['message']['content']
    else
        return nil
    end
end

options = {}
OptionParser.new do |opts|
  opts.on("-f", "--from FROM", "Language to translate from") { |f| options[:from] = f }
  opts.on("-t", "--to TO", "Language to translate to") { |t| options[:to] = t }
end.parse!

from_language = options[:from]
to_language = options[:to]

if from_language.nil? || to_language.nil?
  puts "Error: Incomplete required parameters. See --help for more information."
  exit
end

json_input = ARGF.read
dictionary = load_json("../assets/data/dict.json")

parsed_input = JSON.parse(json_input)
strange_keywords = parsed_input['keywords'].select { |str| !dictionary.key?(str) }
parsed_input['translations'] = JSON.parse(generate_translations(strange_keywords, from_language, to_language))

puts parsed_input.to_json
