local input = std.filter(function(x) std.length(x) > 0, std.split(importstr 'input', '\n'));

local target = 2020;

local inputNums = [std.parseInt(n) for n in input];

local sorted = std.sort(inputNums);

local ceiling = 2020 - sorted[0] - sorted[1];

local viable = [n for n in sorted if n <= ceiling];

viable
#[
#  n1, n2, n3
#  for n in [n for n in sorted if n <= ceiling]
#  if n
#  if std.member(viable, target - n2 - n3)
#  for n2 in viable
#]
#local answers = [ n for n in viable if std.member(viable, target - n) ];
#
#std.foldl(function(x, y) x * y, answers, 1)
