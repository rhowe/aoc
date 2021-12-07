local input = std.sort(std.map(std.parseInt, std.split(std.rstripChars(importstr 'input', '\n'), ',')));

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

local arraydelta(x, arr) = std.map(function(e) local dist = std.abs(e-x); (dist + 1) * (dist / 2), arr);

local min = std.sort(input)[0];
local max = std.sort(input)[std.length(input) - 1];

local distances = std.map(sumarray, std.map(function(x) arraydelta(x, input), std.range(min, max)));

std.sort(distances)[0]
