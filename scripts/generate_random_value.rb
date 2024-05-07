values = ARGV[0].split("/")
weighted_values = values.map { |v| v.split("@") }
weighted_values.map! { |v| v.length > 1 ? [v[0], v[1].to_i] : [v[0], 1] }.flatten(1)
weighted_values = weighted_values.map { |v| [v[0]] * v[1]}.flatten
random_value = weighted_values.sample
puts random_value