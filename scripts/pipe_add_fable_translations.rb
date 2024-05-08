require 'json'
require 'net/http'
require 'uri'
require 'securerandom'
require 'optparse'

LANG_CODE = {
    "id" => "indonesian",
    "en" => "english",
    "pt" => "portuguese/brazilian",
    "fr" => "french",
    "de" => "deutsch",
}

def clean_json(txt)
  txt.gsub!('```json', '')
  txt.gsub!('```', '')
  txt.gsub!(/,\s+\]/, ']')
  return txt
end

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

def generate_keywords_translations(words, from_language, to_language)
    if words == []
        return []
    end

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
            "content": "Generate literal translations for below words. Can be multiple words for common synonyms. all words uses lowercase. \nWords: ['#{words.join("','")}']\nFrom: #{from_language}\nTo: #{to_language}\nFormat: JSON Map<string, string[]> (keyword to translations)"
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

def generate_metadata_translations(source, target, complexity, metadatas)
    api_key = ENV['OPENAI_API_KEY']
    raise "OpenAI API key not found in environment variables." if api_key.nil?

    uri = URI('https://api.openai.com/v1/chat/completions')
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {
                "role": "system",
                "content": "You work on company generating fables to learn language. Compact answer in requested format."
            },
            {
            "role": "user",
            "content": "Generate translations for story metadatas below. \nSource Language: #{source}\nTarget Language: #{target}\nVocabulary & Complexity Level: #{complexity + 5}yo local speaker.\nFormat: Valid JSON Object {title:string(in #{target}),hook:string (in #{source}),moral:string (in #{source})} (no markdown script tag & ensure valid JSON object structure!)\nMetadata:\n#{metadatas}"
            },
        ],
        "temperature": 1,
        "max_tokens": 1200,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
    }

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{api_key}"
    req.body = data.to_json
    
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

def generate_paragraph_translations(language, complexity, paragraphs)
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
                "content": "Generate sentence-by-sentence translations for below paragraphs in target language. Add list of learnable foreign terms/words used in the translated story as keywords.\n\nTarget Language: #{language}\nTarget Language Vocabulary & Complexity Level: #{complexity}yo local speaker\nFormat: {paragraphs:string[],keywords:string[8-15]} (no markdown script tag & ensure valid JSON object structure!)\nParagraphs:\n#{paragraphs}"
            }
        ],
        "temperature": 1,
        "max_tokens": 4096,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0
    }

    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['Authorization'] = "Bearer #{api_key}"
    req.body = data.to_json
    
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

def exec(parsed_input, from_language, to_language, complexity)
    # extract data from parsed input
    title = parsed_input['title']
    hook = parsed_input['hook']
    moral = parsed_input['moral']
    paragraphs = parsed_input['paragraphs']
    keywords = parsed_input['keywords']
    
    # prepare metadata strings for translation
    strmetadatas = <<~MD
    ---
    title: #{title}
    hook: #{hook}
    moral: #{moral}
    MD

    # prepare paragraph strings for translation
    strparagraphs = <<~MD
    ---
    #{paragraphs.join("\n\n")}
    MD

    # translate metadata
    translated_metadata = JSON.parse(clean_json generate_metadata_translations(LANG_CODE[from_language], LANG_CODE[to_language], complexity, strmetadatas))
    
    # translate paragraphs
    translated_paragraphs = {'paragraphs' => paragraphs, 'keywords' => keywords}
    if to_language != 'en'
        translated_paragraphs = JSON.parse(clean_json generate_paragraph_translations(LANG_CODE[to_language], 3, strparagraphs))
    end
    
    # translate keywords
    keywords_translations = JSON.parse(clean_json generate_keywords_translations(translated_paragraphs['keywords'], LANG_CODE[to_language], LANG_CODE[from_language]))
    
    # merge translations
    translation = translated_metadata.merge(translated_paragraphs)
    translation['keywords'] = keywords_translations
    
    # adjust if target language is english
    if to_language == 'en'
        translation['title'] = title
        translation['paragraphs'] = ''
    end
    
    # output final json
    return translation
end

parsed_input = JSON.parse($stdin.read)
input_data = ARGV

language_pairs = input_data.map { |pair| pair.split('@') }

results = {}
threads = []

# Process each language pair and complexity
language_pairs.each do |pair, complexity|
  from_language, to_language = pair.split('-')

  # Spawn a new thread for each execution
  threads << Thread.new {
    result = exec(parsed_input, from_language, to_language, complexity.to_i)
    results[pair] = result
  }
end

# Wait for all threads to finish
threads.each(&:join)

# assign the results
parsed_input['translations'] = parsed_input['translations'].merge(results)

# Output the results
puts parsed_input.to_json