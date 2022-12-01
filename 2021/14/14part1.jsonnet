local input = std.split(std.rstripChars(importstr 'input', '\n'), '\n');

local template = input[0];

local mappings = {
  [std.split(mapping, '>')[0][0:2]]: local parts = std.split(mapping, '>'); parts[0][0:1] + parts[1][1:2]
  for mapping in input[2:std.length(input)]
};

local expandtemplate = function(template) std.map(function(idx) template[idx:idx+2], std.range(0, std.length(template) - 1));

local step = function(val) std.join('', std.map(function(x) if std.length(x) == 1 then x else mappings[x], expandtemplate(val)));

local result = std.foldl(function(acc, x) step(acc), std.range(0, 9), template);

local freq = function(arr) {
  [e]: std.count(arr, e)
  for e in std.set(arr)
};

local fdist = freq(std.stringChars(result));

local frequencies = std.sort(std.objectValues(fdist));

frequencies[std.length(frequencies)-1] - frequencies[0]

