local input = std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

std.count(std.map(function(idx) input[idx + 3] > input[idx], std.range(0, std.length(input) - 4)), true)
