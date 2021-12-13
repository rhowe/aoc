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

local foldy = function(dots, y)
  [
    if dot[1] < y then dot else [dot[0], y-(dot[1] - y)]
    for dot in dots
  ];

local foldx = function(dots, x)
  [
    if dot[0] < x then dot else [x-(dot[0] - x), dot[1]]
    for dot in dots
  ];

local fold = function(dots, instruction)
  std.set(if instruction[0] == 'x'
    then foldx(dots, instruction[1])
  else foldy(dots, instruction[1]));

std.length(fold(dots, folds[0]))
