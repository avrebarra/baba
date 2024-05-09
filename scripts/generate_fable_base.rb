#!/usr/bin/env ruby

require_relative "../_builder/libs/babba"

def raise_missing(msg) = raise(OptionParser::MissingArgument, msg)

options = {}
OptionParser
  .new do |opts|
    opts.on(
      "-s",
      "--size FABLE_SIZE",
      "Expected size (wordlength) for fable"
    ) { |t| options[:size] = t }
    opts.on(
      "-l",
      "--level LEVEL_COMPLEXITY",
      "Level of language complexity of fable"
    ) { |t| options[:level] = t }
    opts.on(
      "-c",
      "--character CHARACTER_HINT",
      "Type of character used on the fable"
    ) { |t| options[:character] = t }
    opts.on(
      "-m",
      "--mood GENERAL_MOOD_HINT",
      "Hint for the mood of the fable"
    ) { |t| options[:mood] = t }
    opts.on(
      "-i",
      "--influence CULTURAL_INFLUENCE",
      "Hint for the cultural influence in the fable"
    ) { |t| options[:influence] = t }
  end
  .parse!

api_key = ENV["OPENAI_API_KEY"] || raise("No OPENAI_API_KEY in env vars")
level = options[:level]
character = options[:character]
mood = options[:mood]
influence = options[:influence]
size = options[:size]

out =
  Babba.generate_fable(
    openai_api_key: api_key,
    words_length_range: size,
    language_complexity: level,
    hint_cultural_influence: influence,
    hint_mood: mood,
    hint_character: character
  )

out["translations"] = {}

puts out.to_json
