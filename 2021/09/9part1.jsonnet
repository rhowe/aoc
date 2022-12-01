local input = [
  std.map(function(x) std.parseInt(x) + 1, std.stringChars(line))
  for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
];

local height = std.length(input);
local width  = std.length(input[0]);

local lowpoint = function(x, y)
  local cell = input[y][x];
  local left  = if x > 0          then input[y][x - 1] > cell else true;
  local right = if x < width - 1  then input[y][x + 1] > cell else true;
  local up    = if y > 0          then input[y-1][x]   > cell else true;
  local down  = if y < height - 1 then input[y+1][x]   > cell else true;
  left && right && up && down;

local lowpoints = std.mapWithIndex(function(y, row) std.mapWithIndex(function(x, cell) lowpoint(x,y), row), input);

local masked_input = std.mapWithIndex(function(y, row) std.mapWithIndex(function(x, cell) if lowpoints[y][x] then cell else 0, row), input);

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

sumarray(std.flattenArrays(masked_input))
