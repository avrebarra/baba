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
            "content": "Generate sentence-by-sentence translations for below story metadata. \nSource Lang: #{source}\nTarget Lang: #{target}\nTarget Language Complexity Level for Moral & Hook: #{complexity + 5}yo local speaker\nFormat: JSON Object {title:string(in target language),hook:string (in source language),moral:string (in source language)} (no markdown script tag & ensure no trailing commas!)\nMetadata:\n#{metadatas}"
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
                "content": "Generate literal sentence-by-sentence translations for below paragraphs. Also add list of learnable foreign terms/words used in the translated story as keywords.\n\nSource Lang: english\nTarget Lang: #{language}\nTarget Language Complexity Level: #{complexity}yo local speaker\nFormat: {paragraphs:string[],keywords:string[8-15]} (no markdown script tag & ensure no trailing commas!)\nParagraphs:\n#{paragraphs}"
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

options = {}
OptionParser.new do |opts|
  opts.on("-f", "--from FROM", "Language to translate from") { |f| options[:from] = f }
  opts.on("-t", "--to TO", "Language to translate to") { |t| options[:to] = t }
  opts.on("-c", "--to COMPLEXITY", "Language complexity level to translate to") { |t| options[:complexity] = t }
end.parse!

from_language = options[:from]
to_language = options[:to]
complexity = Integer(options[:complexity])

if from_language.nil? || to_language.nil? || complexity == 0
  puts "Error: Incomplete required parameters. See --help for more information."
  exit
end

parsed_input = JSON.parse(ARGF.read)

title = parsed_input['title']
hook = parsed_input['hook']
moral = parsed_input['moral']
paragraphs = parsed_input['paragraphs']
keywords = parsed_input['keywords']

strmetadatas = <<~MD
---
title: #{title}
hook: #{hook}
moral: #{moral}
MD

strparagraphs = <<~MD
---
#{paragraphs.join("\n\n")}
MD

translated_metadata = JSON.parse(clean_json generate_metadata_translations(LANG_CODE[from_language], LANG_CODE[to_language], complexity, strmetadatas))
translated_paragraphs = {'paragraphs' => paragraphs, 'keywords' => keywords}
if to_language != 'en'
    translated_paragraphs = JSON.parse(clean_json generate_paragraph_translations(LANG_CODE[to_language], 3, strparagraphs))
end
keywords_translations = JSON.parse(clean_json generate_keywords_translations(translated_paragraphs['keywords'], LANG_CODE[to_language], LANG_CODE[from_language]))

translation = translated_metadata.merge(translated_paragraphs)
translation['keywords'] = keywords_translations
if to_language == 'en'
    translation['title'] = title
    translation['paragraphs'] = ''
end

parsed_input['translations']["#{from_language}-#{to_language}"] = translation

puts parsed_input.to_json