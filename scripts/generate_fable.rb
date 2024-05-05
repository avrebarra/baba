require 'net/http'
require 'json'
require 'uri'
require 'securerandom'
require 'optparse'

def generate_fable(language, theme, complexity_level)
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
          "content": "Generate 200-250 words mature themed fables. Use clear sentence structures as much as possible. Give breathtaking conflict/climax. Split into paragraphs. Also add list of learnable words as keywords.\nLanguage: #{language}\nTheme: #{theme}\nLanguage complexity level: #{complexity_level}yo local speaker.\nFormat: JSON {title:string,paragraphs:string[],moral:string,keywords:string[5-10]} (without markdown script tag + ensure no trailing commas!)\n"
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
  opts.on("-l", "--language LANGUAGE", "Language of the fable") { |l| options[:language] = l }
  opts.on("-t", "--theme THEME", "Theme of the fable") { |t| options[:theme] = t }
  opts.on("-c", "--complexity COMPLEXITY", "Language complexity level") { |c| options[:complexity] = c }
end.parse!

language = options[:language]
theme = options[:theme]
complexity = options[:complexity]

if language.nil? || theme.nil? || complexity.nil?
  puts "Error: incomplete required params. See --help for more informations."
  exit
end

puts generate_fable(language, theme, complexity)
