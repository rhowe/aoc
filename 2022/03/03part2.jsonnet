local input = std.rstripChars(importstr 'input', '\n');

local sum = function(a, b) a + b;
local sumarray = function(arr) std.foldl(sum, arr, 0);
local splitlines = function(str) std.split(str, '\n');

local array_intersection = function(pair) std.setInter(std.set(pair[0]), std.set(pair[1]));
local ord_a = std.codepoint('a');
local ord_A = std.codepoint('A');

local priority = function(item)
  local ord = std.codepoint(item);
  ord - if ord >= ord_a then ord_a - 1 else ord_A - 27;


local lines = splitlines(input);

local groups = std.map(function(idx) local offset = idx * 3; lines[offset:offset + 3], std.range(0, std.length(lines) / 3 - 1));
local group_items = std.map(function(group) std.map(std.stringChars, group), groups);
local array_intersection3 = function(arr) array_intersection([array_intersection([arr[0], arr[1]]), arr[2]]);

sumarray(std.map(priority, std.map(function(group) array_intersection3(group)[0], group_items)))
