# Needs a big stack - run with jsonnet -s 10000
local input = std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

std.foldl(function (acc, curr) [ curr, acc[1] + if curr > acc[0] then 1 else 0], input, [0, 0])[1] - 1
