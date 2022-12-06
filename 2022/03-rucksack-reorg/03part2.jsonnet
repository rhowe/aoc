local input = std.rstripChars(importstr 'input', '\n');

local sum(a, b) = a + b;
local sumarray(arr) = std.foldl(sum, arr, 0);
local splitlines(str) = std.split(str, '\n');

local ord_a = std.codepoint('a');
local ord_A = std.codepoint('A');

local priority(item) =
  local ord = std.codepoint(item);
  ord - if ord >= ord_a then ord_a - 1 else ord_A - 27;

local lines = splitlines(input);

local array_intersection(pair) = std.setInter(std.set(pair[0]), std.set(pair[1]));
local array_intersection3(arr) = array_intersection([array_intersection([arr[0], arr[1]]), arr[2]]);

sumarray([
  priority(item)
  for item in [
    array_intersection3(group)[0]
    for group in [
      [
        std.stringChars(part)
        for part in group
      ]
      for group in [
        local offset = idx * 3;

        lines[offset:offset + 3]
        for idx in std.range(0, std.length(lines) / 3 - 1)
      ]
    ]
  ]
])
