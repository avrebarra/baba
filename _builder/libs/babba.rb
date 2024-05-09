require "json"
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
  def self.generate_fable(
    openai_api_key:,
    language_complexity: 3,
    words_length_range: "250-350",
    hint_cultural_influence: nil,
    hint_mood: nil,
    hint_character: nil
  )
    OpenAI.prompt(
      openai_api_key,
      "You work on company generating fables to learn foreign language. Compact answer in requested format.",
      <<~PROMPT
        Create original fable paragraphs in English within #{words_length_range} words.
        Write in vocabulary complexity suitable for #{language_complexity}yo local speaker.
        Use basic, descriptive, clear sentence structures. Give dialogues. Give conflicts. Structure into paragraphs.
        Also generate story hook with curiosity hooking question (max 3 sentences) for story overview.
        Also generate list of keywords for good vocabulary enriching.
        #{"Use #{hint_character} as character." unless hint_character.nil?}
        #{"Use #{hint_mood} as story mood." unless hint_mood.nil?}
        #{"Use #{hint_cultural_influence} as cultural influence." unless hint_cultural_influence.nil?}

        Output Format: JSON {title: string, hook: string, moral: string, paragraphs: string[], keywords: string[10-15 words]} (MUST ensure valid JSON object structure!)
      PROMPT
    )
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
    OpenAI.prompt(
      openai_api_key,
      "You work on company generating fables to learn foreign language. Compact answer in requested format.",
      <<~PROMPT
        Translate text #{"from #{from_lang}" if from_lang} to #{to_lang}. #{"Literal word-by-word translations." if use_literal}
        Use vocabulary & sentence structure suitable for #{language_complexity}yo #{to_lang} people.
        #{"Generate a list of #{to_lang} keywords (#{extract_keyterms}) used in translation to enrich vocabulary." if extract_keyterms > 0}
        #{"Adjust text to prioritize comprehensibility for age. Use lingua-francas." if use_linguafranca}
        #{"Notes: #{notes}" unless notes.nil?}
        Output Format: JSON {translated: string#{", keywords: string[#{extract_keyterms}]" if extract_keyterms > 0}} (ENSURE valid JSON object structure!)
        Text to translate: #{text}
      PROMPT
    )
  end

  def self.translate_keywords(api_key:, words:, from: "en", to:)
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
end
