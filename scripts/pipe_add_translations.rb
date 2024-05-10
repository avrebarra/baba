#!/usr/bin/env ruby

require_relative "../_builder/libs/openai"
require_relative "../_builder/libs/babba"

api_key = ENV["OPENAI_API_KEY"] || raise("No OPENAI_API_KEY in env vars")

def raise_missing(msg) = raise(OptionParser::MissingArgument, msg)

fable = JSON.parse $stdin.read
language_pairs = ARGV.map { |translation_code| translation_code.split("@") }

translations = {}
threads = []
language_pairs.each do |translation_code, complexity|
  from_lang, to_lang = translation_code.split("-")
  threads << Thread.new do
    t =
      Babba.generate_translation(
        openai_api_key: api_key,
        fable: fable,
        from: from_lang,
        to: to_lang,
        language_complexity: complexity
      )
    translations[translation_code] = t
  end
end
threads.each(&:join)

fable["translations"] = fable["translations"].merge(translations)

puts fable.to_json
