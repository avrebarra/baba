# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'
require 'securerandom'
require 'optparse'

module OpenAI # rubocop:disable Style/Documentation
  def self.clean_resp(txt)
    txt.gsub!('```json', '')
    txt.gsub!('```yaml', '')
    txt.gsub!('```yml', '')
    txt.gsub!('```', '')
    txt.gsub!(/,\s+\]/, ']')
    txt
  end

  def self.prompt(api_key, condition, prompts) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    raise 'OpenAI API key not defined.' if api_key.nil?

    uri = URI.parse('https://api.openai.com/v1/chat/completions')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/json'
    request['Authorization'] = "Bearer #{api_key}"

    data = {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": condition },
        { "role": 'user', "content": prompts }
      ],
      "temperature": 1,
      "max_tokens": 4096,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0
    }

    request.body = data.to_json

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    return nil unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse response.body
    clean_resp result.dig('choices', 0, 'message', 'content')
  end
end
