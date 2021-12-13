# run with jsonnet -S 13part2.jsonnet

local parsefold = function(instruction)
  local fold = std.split(std.split(instruction, ' ')[2], '=');
  [fold[0], std.parseInt(fold[1])];

local input = std.foldl(
  function(acc, x) if x == '' then acc
    else if x[0] == 'f' then [acc[0], std.join([], [acc[1], [parsefold(x)]])]
    else [std.join([], [acc[0], [std.map(std.parseInt, std.split(x, ','))]]), acc[1]],
  std.split(std.rstripChars(importstr 'input', '\n'), '\n'),
  [[],[]]);

local dots = std.set(input[0]);
local folds = input[1];

local fold = function(dots, instruction)
  local offset = instruction[1];
  std.set([
    [
      if instruction[0] == 'x' && dot[0] > offset then offset+offset-dot[0] else dot[0],
      if instruction[0] == 'y' && dot[1] > offset then offset+offset-dot[1] else dot[1]
    ]
    for dot in dots
  ]);

local pic = std.foldl(fold, folds, dots);

local xmax = std.sort([p[0] for p in pic])[std.length(pic) - 1];
local ymax = std.sort([p[1] for p in pic])[std.length(pic) - 1];

std.join('\n', [
  std.join('', std.makeArray(xmax + 1, function(x) if std.member(pic, [x, y]) then '#' else ' '))
  for y in std.range(0, ymax)
])
