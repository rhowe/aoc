local input = local input = [
    local row = std.map(function(x) std.parseInt(x), std.stringChars(line));
    std.join([], [[9], row, [9]])
    for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
  ];
  local hr = std.makeArray(std.length(input[0]), function(x) 9);
  std.join([], [[hr], input, [hr]])
;

local height = std.length(input);
local width  = std.length(input[0]);

local lowpoint = function(x, y)
  local cell = input[y][x];
  local left  = if x > 0          then input[y][x - 1] > cell else true;
  local right = if x < width - 1  then input[y][x + 1] > cell else true;
  local up    = if y > 0          then input[y-1][x]   > cell else true;
  local down  = if y < height - 1 then input[y+1][x]   > cell else true;
  left && right && up && down;

local lowpointmap = std.mapWithIndex(function(y, row) std.mapWithIndex(function(x, cell) lowpoint(x,y), row), input);

local map2dWithIndex = function(func, arr)
  std.mapWithIndex(function(y, row)
    std.mapWithIndex(function(x, cell) func(x, y, arr), row), arr);

local lowpoints = std.join([], std.prune(
	map2dWithIndex(function(x, y, arr) if arr[y][x] then [x,y] else [], lowpointmap)));

local map = map2dWithIndex(function(x, y, arr)
    if arr[y][x] == 9 then 'x'
    else if std.member(lowpoints, [x,y]) then std.find([x,y], lowpoints)[0]
    else ' ', input);

local fillvalue = function(x, y, map)
  local cell = map[y][x];
  if cell != ' ' then cell
  else 
  local left  = map[y][x-1];
  local right = map[y][x+1];
  local up    = map[y-1][x];
  local down  = map[y+1][x];
  if !std.member(['x', ' '], left) then left
  else if !std.member(['x', ' '], right) then right
  else if !std.member(['x', ' '], up) then up
  else if !std.member(['x', ' '], down) then down
  else cell;

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

local count2d = function(arr, x) sumarray([
 std.count(std.map(std.toString, row), x)
 for row in arr
]);

local fill = function(arr)
  if count2d(arr, ' ') == 0 then arr
  else fill(map2dWithIndex(fillvalue, arr))
;

local filledmap = fill(map);

local basinsizes = std.sort(std.makeArray(std.length(lowpoints), function(x) count2d(filledmap, std.toString(x))), function(x) -x);

basinsizes[0] * basinsizes[1] * basinsizes[2]
