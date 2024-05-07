require 'net/http'
require 'json'
require 'uri'
require 'securerandom'
require 'optparse'

def clean_json(txt)
  txt.gsub!('```json', '')
  txt.gsub!('```', '')
  txt.gsub!(/,\s+\]/, ']')
  return txt
end

def generate_fable(mood, complexity_level, culture, character)
    api_key = ENV['OPENAI_API_KEY']
    raise "OpenAI API key not found in environment variables." if api_key.nil?

    uri = URI.parse("https://api.openai.com/v1/chat/completions")
    request = Net::HTTP::Post.new(uri)
    request.content_type = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    
    data = {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "You work on company generating daily mature fables to learn foreign language. Compact answer in requested format."
        },
        {
          "role": "user",
          "content": "Generate original 300-400 words fables in english language. Use clear sentence structures as much as possible. Use #{character} category as main character. Give reasonable conflict/climax. Split into paragraphs. Also add short english storyline hook with closing curiosity hook question (max 3 sentences), that will be shown in overview. Also add list of learnable foreign terms/words used in the translated story as keywords. \nLanguage: english\nMood: #{mood}\nCultural Influence: #{culture}\nTheme: any\nLanguage complexity level: #{complexity_level}yo local speaker.\nFormat: JSON {title:string,hook:string(en),moral:string(en),paragraphs:string[],keywords:string[8-15]} (without markdown script tag & ensure no trailing commas!)\n"
        }
      ],
      "temperature": 1,
      "max_tokens": 2452,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0
    }

    request.body = data.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request(request)
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
  opts.on("-u", "--character CHARACTER", "Type of character used on the fable") { |t| options[:character] = t }
  opts.on("-n", "--culture CULTURE", "Culture base of the fable") { |t| options[:culture] = t }
  opts.on("-m", "--mood MOOD", "Mood of the fable") { |t| options[:mood] = t }
  opts.on("-c", "--complexity COMPLEXITY", "Language complexity level") { |c| options[:complexity] = c }
end.parse!

mood = options[:mood]
character = options[:character]
complexity = options[:complexity]
culture = options[:culture]

if theme.nil? || complexity.nil? || culture.nil? || character.nil?
  puts "Error: incomplete required params. See --help for more informations."
  exit
end

out = JSON.parse(clean_json generate_fable(mood, complexity, culture, character))
out['keywords'] = out['keywords'].map(&:downcase)
out['translations'] = {}
puts out.to_json
