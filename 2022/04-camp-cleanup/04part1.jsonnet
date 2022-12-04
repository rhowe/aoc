local input = std.rstripChars(importstr 'input', '\n');

local sum = function(a, b) a + b;
local sumarray = function(arr) std.foldl(sum, arr, 0);
local splitlines = function(str) std.split(str, '\n');
local splitcsv = function(str) std.split(str, ',');
local splitrange = function(str) std.map(std.parseInt, std.split(str, '-'));

local is_pair_nested(pairs) =
  local p1_l = pairs[0][0];
  local p1_r = pairs[0][1];
  local p2_l = pairs[1][0];
  local p2_r = pairs[1][1];
  p1_l == p2_l
  || p1_r == p2_r
  || (p1_l < p2_l && p1_r > p2_r)
  || (p2_l < p1_l && p2_r > p1_r)
;

std.length(std.filter(is_pair_nested, std.map(function(line) std.map(splitrange, splitcsv(line)), splitlines(input))))
