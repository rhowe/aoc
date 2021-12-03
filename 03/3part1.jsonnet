local input = std.map(function(x) std.map(function(x) x == '1', std.stringChars(x)), std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

local freq = std.flatMap(function(x) std.find(true, x), input);

local freqsum = std.map(function(x) std.count(freq, x), std.range(0, std.length(input[0]) - 1));

local threshold = std.length(input) / 2;

local gammabits = std.map(function(x) x > threshold, freqsum);
local epsilonbits = std.map(function(x) !x, gammabits);

local sum(arr) = std.foldl(function(total, x) total + x, arr, 0);

local binarr2dec = function(arr) sum(std.mapWithIndex(function (idx, e) if e then std.pow(2, idx) else 0, std.reverse(arr)));
binarr2dec(gammabits) * binarr2dec(epsilonbits)
