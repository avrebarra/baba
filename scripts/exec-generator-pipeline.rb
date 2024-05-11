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

series = {
  "none" => [],
  "young-babas-experiences" => {
    "sets" => "Story happened around home and daily life experiences.",
    "characters" => [
      "Baba, jolly cute wholesome little girl"
      # "Baba, jolly teenage tough unique girl"
    ]
  },
  "fables-of-fora-forests" => {
    "sets" =>
      "Story happens around great Fora jungle. Where the characters are originated from.",
    "characters" => [
      "Amia, gentle-hearted flower fairy",
      "Asha, compassionate healer dragoness",
      "Jia and Rua, mischievous moonlight pixies",
      "Kai, mysterious shadow-dwelling imp",
      "Kata, gentle dream-weaving caterpillar",
      "Kian, strong loyal tiger",
      "Kimi, now-wise old storytelling fox",
      "Leela, kind-hearted river mermaid",
      "Liwei, creative rice farmer",
      "Luna, curious star-gazing young owl",
      "Maila, helpful garden fairy",
      "Milo, brave little mouse. King of the forest",
      "Nisha and Kavia, clever wandering merchant girls duo",
      "Nuri, mischievous forest spirit",
      "Quira, strong willed desert wanderer",
      "Ravi, adventurous young mapmaker",
      "Surya, spirited time leaping pirate",
      "Washa, wise serpent charmer",
      "Xia, swift-footed mountain goat",
      "Zoran, gentle singing pirate"
    ]
  }
}

fablegroup = series.keys.sample
fabledata = series[fablegroup]
command = <<~COMMAND
  ruby scripts/generate_fable_base.rb \
  -i 'any' \
  #{"-g '#{fablegroup}'" unless fablegroup == "none"} \
  #{"-m '#{fabledata["sets"]}'" unless fablegroup == "none"} \
  #{"-c '#{fabledata["characters"].sample(rand(1..2)).join(";")}'" unless fablegroup == "none"} \
  -l 3 -s '150-200' \
  | ruby scripts/pipe_add_translations.rb 'en-pt@3' 'id-en@3' 'en-de@3' 'en-fr@3'\
  | ruby scripts/funnel_register_story.rb \
  | ruby scripts/funnel_register_translations.rb \
  > /dev/null
COMMAND

puts command

system(command)

puts "finished in #{Time.now - start_time} seconds"
