local input = std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

std.count(std.mapWithIndex(function(idx, x) input[idx + 3] > input[idx], std.makeArray(std.length(input) - 3, function(x) input[x])), true)
