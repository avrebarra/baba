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

def generate_fable(theme, complexity_level, culture)
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
          "content": "Generate original 300-400 words fables in english language. Use clear sentence structures as much as possible. You can use inanimate object. Give reasonable conflict/climax. Split into paragraphs. Also add short english storyline hook with closing curiosity hook question (max 3 sentences), that will be shown in overview. Also add list of learnable foreign terms/words used in the translated story as keywords. \nLanguage: english\nMood: any\nHappy Ending?: any\nCultural Influence: #{culture}\nTheme: #{theme}\nLanguage complexity level: #{complexity_level}yo local speaker.\nFormat: JSON {title:string,hook:string(en),moral:string(en),paragraphs:string[],keywords:string[8-15]} (without markdown script tag & ensure no trailing commas!)\n"
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
  opts.on("-n", "--culture CULTURE", "Culture base of the fable") { |t| options[:culture] = t }
  opts.on("-t", "--theme THEME", "Theme of the fable") { |t| options[:theme] = t }
  opts.on("-c", "--complexity COMPLEXITY", "Language complexity level") { |c| options[:complexity] = c }
end.parse!

theme = options[:theme]
complexity = options[:complexity]
culture = options[:culture]

if theme.nil? || complexity.nil? || culture.nil?
  puts "Error: incomplete required params. See --help for more informations."
  exit
end

out = JSON.parse(clean_json generate_fable(theme, complexity, culture))
out['keywords'] = out['keywords'].map(&:downcase)
out['translations'] = {}
puts out.to_json
