#!/usr/bin/env ruby

start_time = Time.now

# cultural_influences = [
#   # "Native American lore"
#   # "Ancient Greek mythology",
#   # "Japanese folklore",
#   # "Medieval European traditions",
#   # "African folklore"
#   # "Chinese mythology"
# ].sample

fable_characters = [
  "Amia, gentle-hearted flower fairy",
  "Asha, compassionate healer dragoness",
  "Jia and Rua, mischievous moonlight pixies",
  "Kai, mysterious shadow-dwelling imp",
  "Kata, gentle dream-weaving caterpillar",
  "Kian, strong loyal tiger",
  "Kimi, now-wise old storytelling fox",
  "Leela, kind-hearted river mermaid",
  "Liwei, courageous rice farmer with bad lucks",
  "Luna, curious star-gazing young owl",
  "Maila, helpful garden fairy",
  "Milo, brave little mouse. King of the forest",
  "Nisha and Kavia, clever wandering girl merchants duo",
  "Nuri, mischievous forest spirit",
  "Quira, strong willed desert wanderer",
  "Ravi, adventurous young mapmaker",
  "Surya, spirited time leaping pirate",
  "Washa, wise serpent charmer",
  "Xia, swift-footed mountain goat",
  "Zara, gentle singing mermai."
]

command = <<~COMMAND
  ruby scripts/generate_fable_base.rb -i 'any' -m any -c '#{fable_characters.sample(rand(1..2)).join(";")}' -l 3 -s '150-200' \
  | ruby scripts/pipe_add_translations.rb 'en-pt@3' 'id-en@3' 'en-de@3' 'en-fr@3'\
  | ruby scripts/funnel_register_story.rb \
  | ruby scripts/funnel_register_translations.rb \
  > /dev/null
COMMAND

system(command)

puts "finished in #{Time.now - start_time} seconds"
