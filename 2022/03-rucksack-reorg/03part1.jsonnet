local input = std.rstripChars(importstr 'input', '\n');

local sum = function(a, b) a + b;
local sumarray = function(arr) std.foldl(sum, arr, 0);
local splitlines = function(str) std.split(str, '\n');

local bisect = function(str) local len = std.length(str); [str[0:len / 2], str[len / 2:]];
local array_intersection = function(pair) std.setInter(std.set(pair[0]), std.set(pair[1]));
local ord_a = std.codepoint('a');
local ord_A = std.codepoint('A');

local priority = function(item)
  local ord = std.codepoint(item);
  ord - if ord >= ord_a then ord_a - 1 else ord_A - 27;

sumarray(std.map(priority, std.map(function(pair) array_intersection(pair)[0], std.map(bisect, std.map(std.stringChars, splitlines(input))))))
