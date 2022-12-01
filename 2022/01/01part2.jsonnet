local input = std.split(std.rstripChars(importstr 'input', '\n'), '\n');

local appendchunk = function(acc, curr)
  if curr == ''
  then acc + [[]]
  else std.slice(acc, 0, std.length(acc) - 1, 1) + [acc[std.length(acc) - 1] + [std.parseInt(curr)]];

local chunkedinput = std.foldl(appendchunk, [''] + input, []);

local sumarrays = std.map(function(x) std.foldl(function(acc, elem) acc + elem, x, 0), chunkedinput);

local sortedlist = std.sort(sumarrays, function(x) -x);
std.foldl(function(acc, curr) acc + curr, std.slice(sortedlist, 0, 3, 1), 0)
