require 'json'

# Read the JSON input from pipe
json_input = ARGF.read

# Remove trailing commas in arrays
json_input.gsub!(/,\s+\]/, ']')

# Parse the processed JSON
parsed_json = JSON.parse(json_input)

# Output the result to stdout
puts JSON.generate(parsed_json)
