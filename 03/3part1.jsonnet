local input = std.map(function(x) std.map(std.parseInt, std.stringChars(x)), std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

local freq = std.flatMap(function(x) std.find(1, x), input);

local freqsum = std.map(function(x) std.count(freq, x), std.range(0, std.length(input[0]) - 1));

local threshold = std.length(input) / 2;

local gammabits = std.map(function(x) if x > threshold then 1 else 0, freqsum);
local epsilonbits = std.map(function(x) if x == 0 then 1 else 0, gammabits);

local binarr2dec = function(arr) std.foldl(function(acc, x) acc + x, std.mapWithIndex(function (idx, e) e * std.pow(2, idx), std.reverse(arr)), 0);

binarr2dec(gammabits) * binarr2dec(epsilonbits)
