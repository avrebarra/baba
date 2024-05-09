#!/usr/bin/env ruby

require_relative "../_builder/libs/openai"
require_relative "../_builder/libs/babba"

api_key = ENV["OPENAI_API_KEY"] || raise("No OPENAI_API_KEY in env vars")

def raise_missing(msg) = raise(OptionParser::MissingArgument, msg)
def lang_name(code) = LANG_CODE[code]

def make_metadata_translation(api_key:, words:, from: "en", to:)
  from = lang_name(from)
  to = lang_name(to)

  OpenAI.prompt(
    api_key,
    "You work on company generating fables to learn foreign language. Compact answer in requested format.",
    <<~PROMPT
        Generate translations map of these words #{"from #{from}" if from} for #{to} languages.
        Can be multiple words for common synonyms of each words.
        Words: ['#{words.join("','")}']
        Output Format: JSON Map<string, string[]> (word to translations)
      PROMPT
  )
end

def make_translation(api_key:, storybase:, from: "en", to:)
  # perform translations
  translation = {}
  threads = []

  t =
    lambda do |text, notes = nil|
      out =
        Babba.translate(
          openai_api_key: api_key,
          text: text,
          notes: notes,
          to_lang: lang_name(to)
        )
      out["translated"]
    end

  threads << Thread.new { translation["hook"] = t.call storybase["hook"] }
  threads << Thread.new { translation["moral"] = t.call storybase["moral"] }
  threads << Thread.new do
    translation["title"] = t.call storybase["title"], "it's a title text"
  end

  paragraphs_itv = {}
  keywords = []
  storybase["paragraphs"].each_with_index do |v, i|
    threads << Thread.new do
      out =
        Babba.translate(
          openai_api_key: api_key,
          text: v,
          to_lang: lang_name(to),
          use_linguafranca: true,
          extract_keyterms: 3
        )
      paragraphs_itv[i] = out["translated"]
      keywords = keywords | out["keywords"]
    end
  end

  threads.each(&:join)

  # make keywords translation
  translation["keywords"] = make_metadata_translation(
    api_key: api_key,
    words: keywords,
    to: from
  )

  # rearrange paragraphs
  translation["paragraphs"] = []
  paragraphs_itv.each { |i, v| translation["paragraphs"][i] = v }

  translation
end

input = JSON.parse $stdin.read
language_pairs = ARGV.map { |pair| pair.split("@") }

results = {}
threads = []
language_pairs.each do |pair, complexity|
  _, to_language = pair.split("-")
  threads << Thread.new do
    t = make_translation(api_key: api_key, storybase: input, to: to_language)
    results[pair] = t
  end
end
threads.each(&:join)

input["translations"] = input["translations"].merge(results)
puts input.to_json
