require "json"
require "yaml"
require "net/http"
require_relative "./openai"

LANG_CODE = {
  "id" => "indonesian",
  "en" => "english",
  "pt" => "portuguese/brazilian",
  "fr" => "french",
  "de" => "deutsch"
}

module Babba
  def self.clean_yaml(yaml_string)
    yaml_string
      .split("\n")
      .map do |line|
        if line.strip.start_with?("- ")
          "- \"#{line.strip[2..-1].gsub(/"/, '\\"')}\""
        else
          line
        end
      end
      .join("\n")
  end

  def self.generate_fable(
    openai_api_key:,
    language_complexity: 3,
    words_length_range: "250-350",
    hint_cultural_influence: nil,
    hint_mood: nil,
    hint_character: nil
  )
    characters =
      hint_character
        .split(";")
        .map { |txt| txt.split(",").first } unless hint_character.nil?

    out =
      clean_yaml(
        OpenAI.prompt(
          openai_api_key,
          "You work on fable-generating company for all ages. Compact answer in YAML.",
          <<~PROMPT
            Create bitsize fable in English within #{words_length_range} words. Make it a lightread. Style it like Duolingo story.
            Give dialogues. Give unique and original conflicts & resolutions. Give bit more details on the conflict resolutions. Use paragraphs.
            Use vocabulary suitable for #{language_complexity}yo local speaker.
            Use basic & descriptive sentence structures.
            #{"Use #{hint_character} as character. DO NOT involve permanent character/traits/relationship changes when the story ends." unless hint_character.nil?}
            #{"Use #{hint_mood} as story mood." unless hint_mood.nil?}
            #{"Use #{hint_cultural_influence} as cultural influence." unless hint_cultural_influence.nil?}

            Create light non-cheesy moral message of the story. Don't force the moral messages in story paragraph.
            Create story hook with curiosity hooking question (max 3 sentences) for story overview.
            Create list of keywords for good vocabulary enriching.

            Use Output Format: YAML {title: string, hook: string, moral: string, paragraphs: string[], keywords: string[10-15 words]}
          PROMPT
        )
      )

    out = YAML.load out
    out["characters"] = characters
    out
  end

  def self.generate_translation(
    openai_api_key:,
    fable:,
    to:,
    language_complexity: 3,
    from: "en"
  )
    translation = {}
    threads = []

    t =
      lambda do |text, notes = nil|
        out =
          Babba.translate(
            openai_api_key: openai_api_key,
            text: text,
            notes: notes,
            language_complexity: language_complexity,
            to_lang: LANG_CODE[to]
          )
        out["translated"]
      end

    threads << Thread.new do
      translation["hook"] = (
        if to != "en"
          t.call(fable["hook"])
        else
          fable["hook"]
        end
      )
    end

    threads << Thread.new do
      translation["moral"] = (
        if to != "en"
          t.call(fable["moral"])
        else
          fable["moral"]
        end
      )
    end

    threads << Thread.new do
      translation["title"] = (
        if to != "en"
          t.call(fable["title"], "it's a title text")
        else
          fable["title"]
        end
      )
    end

    paragraphs_itv = {}
    keywords = []
    fable["paragraphs"].each_with_index do |v, i|
      threads << Thread.new do
        out =
          Babba.translate(
            openai_api_key: openai_api_key,
            text: v,
            to_lang: LANG_CODE[to],
            use_linguafranca: true,
            extract_keyterms: 3
          )
        paragraphs_itv[i] = out["translated"]
        keywords = keywords | out["keywords"]
      end
    end

    threads.each(&:join)

    # make keywords translation
    translation["keywords"] = Babba.translate_keywords(
      openai_api_key: openai_api_key,
      words: keywords,
      to: from
    )

    # rearrange paragraphs
    translation["paragraphs"] = []
    paragraphs_itv.each { |i, v| translation["paragraphs"][i] = v }

    translation
  end

  def self.translate(
    openai_api_key:,
    text:,
    to_lang:,
    from_lang: nil,
    notes: nil,
    language_complexity: 3,
    use_literal: false,
    use_linguafranca: true,
    extract_keyterms: 0
  )
    out =
      clean_yaml(
        OpenAI.prompt(
          openai_api_key,
          "You work on company generating fables in multi languages. Compact answer in YAML.",
          <<~PROMPT
          Translate text #{"from #{from_lang}" if from_lang} to #{to_lang}. #{"Literal word-by-word translations." if use_literal}
          Use vocabulary suitable for #{language_complexity}yo local speaker. #{"Use lingua-francas." if use_linguafranca}
          Use basic & descriptive sentence structures.
          Do not translate character names.
          #{"Notes: #{notes}" unless notes.nil?}
          #{"Extract #{extract_keyterms} keyterms from result. Without translations." if extract_keyterms > 0}
          Output Format: YAML {translated: string (Use YAML literal block scalar)#{", keywords: string[]" if extract_keyterms > 0}}

          Text to translate: #{text}
        PROMPT
        )
      )
    YAML.load out
  end

  def self.translate_keywords(openai_api_key:, words:, from: "en", to:)
    from = LANG_CODE[from]
    to = LANG_CODE[to]

    out =
      OpenAI.prompt(
        openai_api_key,
        "You work on company generating fables to learn foreign language. Compact answer as JSON Hashmap.",
        <<~PROMPT
          Map these #{"#{from}" if from} words to their #{to} translations.
          Each word can be mapped to multiple words if it has synonymous translations.
          Do not add explanations!!!
          Words List: ['#{words.join("','")}']
          Output Format: Valid JSON HashMap<string, string[]> (map word to translated-words)
        PROMPT
      )

    JSON.parse out
  end
end
