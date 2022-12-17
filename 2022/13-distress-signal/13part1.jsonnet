local sum(a, b) = a + b;
local sumarray(arr) = std.foldl(sum, arr, 0);

local cmp(left, right) =
  local l_sz = std.length(left);
  local r_sz = std.length(right);
  if l_sz == 0 then if r_sz == 0 then 0 else -1
  else if r_sz == 0 then 1
  else
    local l0 = left[0];
    local r0 = right[0];
    local l0_t = std.type(l0);
    local r0_t = std.type(r0);

    local res = if l0_t == 'number' && r0_t == 'number'
    then if l0 < r0 then -1 else if l0 == r0 then 0 else 1
    else cmp(if l0_t == 'array' then l0 else [l0], if r0_t == 'array' then r0 else [r0]);

    if res == 0 then cmp(left[1:l_sz], right[1:r_sz])
    else res;


local packetpairs = [
  [
    std.parseJson(packet)
    for packet in std.split(pair, '\n')
  ]
  for pair in [
    p
    for p in std.split(std.strReplace(std.rstripChars(importstr 'input', '\n'), '\n\n', '^'), '^')
  ]
];

sumarray([
  idx + 1
  for idx in
    std.find(true, [
      cmp(pair[0], pair[1]) == -1
      for pair in packetpairs
    ])
])
