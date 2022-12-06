local input = std.rstripChars(importstr 'input', '\n');

local is_pair_overlapping(pairs) =
  local p1_l = pairs[0][0];
  local p1_r = pairs[0][1];
  local p2_l = pairs[1][0];
  local p2_r = pairs[1][1];
  (p1_l <= p2_r && p1_r >= p2_l)
  || (p2_l <= p1_r && p2_r >= p1_l)
;

std.length(std.filter(is_pair_overlapping, [
  [
    [
      std.parseInt(x)
      for x in std.split(range, '-')
    ]
    for range in std.split(line, ',')
  ]
  for line in std.split(input, '\n')
]))
