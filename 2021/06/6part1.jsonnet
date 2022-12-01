local input = std.sort(std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), ',')));

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

local fish = std.makeArray(9, function(x) std.count(input, x));

local tick = function(fish, t) [ fish[1], fish[2], fish[3], fish[4], fish[5], fish[6], fish[0] + fish[7], fish[8], fish[0] ];

local im = sumarray;
local gonna = std.foldl;
local eat = tick;
local you = function(n) std.range(0, n-1);
local little = 80;
local fishy = fish;

im(gonna(eat, you(little), fishy))
