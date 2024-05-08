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

def generate_fable(mood, complexity_level, culture, character, plot)
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
          "content": "Create concise, original fables in English within 250-350 words. Ensure a coherent plot, using #{character} as character. Employ brief, descriptive sentences with clear structures. Involves dialogues. Introduce impressive conflict and climax. Format into paragraphs. Include a succinct English storyline hook with an ending curiosity hook question (max of 3 sentences) for story overview. Add a list of foreign terms/words as keywords for translation.\nLanguage: English\nMood: #{mood}\nCultural Influence: #{culture}\nVocabulary Complexity Level: #{complexity_level}yo local speaker.\nFormat: Valid JSON {title: string, hook: string(en), moral: string(en), paragraphs: string[], keywords: string[10-15 words]} (no markdown script tag & ensure valid JSON object structure!)"
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
  opts.on("-p", "--plot PLOT", "General plots to inspire from") { |t| options[:plot] = t }
  opts.on("-u", "--character CHARACTER", "Type of character used on the fable") { |t| options[:character] = t }
  opts.on("-n", "--culture CULTURE", "Culture base of the fable") { |t| options[:culture] = t }
  opts.on("-m", "--mood MOOD", "Mood of the fable") { |t| options[:mood] = t }
  opts.on("-c", "--complexity COMPLEXITY", "Language complexity level") { |c| options[:complexity] = c }
end.parse!

plot = options[:plot]
mood = options[:mood]
character = options[:character]
complexity = options[:complexity]
culture = options[:culture]

if mood.nil? || complexity.nil? || culture.nil? || character.nil?
  puts "Error: incomplete required params. See --help for more informations."
  exit
end

out = JSON.parse(clean_json generate_fable(mood, complexity, culture, character, plot))
out['keywords'] = out['keywords'].map(&:downcase)
out['translations'] = {}
puts out.to_json
