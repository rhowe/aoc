# Needs a big stack - run with jsonnet -s 10000
local input = std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

local windowed = std.mapWithIndex(function(idx, x) input[idx] + input[idx+1] + input[idx+2], std.makeArray(std.length(input) - 2, function(x) input[x]));

std.foldl(function (acc, curr) [ curr, acc[1] + if curr > acc[0] then 1 else 0], windowed, [0, 0])[1] - 1
