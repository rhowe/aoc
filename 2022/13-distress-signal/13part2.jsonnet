local sum(a, b) = a + b;
local sumarray(arr) = std.foldl(sum, arr, 0);

local cmp(left, right) =
  local l_sz = std.length(left), r_sz = std.length(right);
  if l_sz == 0 then if r_sz == 0 then 0 else -1
  else if r_sz == 0 then 1
  else
    local l0 = left[0], r0 = right[0];
    local l0_t = std.type(l0), r0_t = std.type(r0);

    local res = if l0_t == 'number' && r0_t == 'number'
    then if l0 < r0 then -1 else if l0 == r0 then 0 else 1
    else cmp(if l0_t == 'array' then l0 else [l0], if r0_t == 'array' then r0 else [r0]) tailstrict;

    if res == 0 then cmp(left[1:], right[1:]) tailstrict
    else res;


local packets = [
  std.parseJson(packet)
  for pair in [
    p
    for p in std.split(std.strReplace(std.rstripChars(importstr 'input', '\n'), '\n\n', '^'), '^')
  ]
  for packet in std.split(pair, '\n')
];

local sort(arr) =
  local merge(a, b) =
    local la = std.length(a), lb = std.length(b);
    local aux(i, j, prefix) =
      if i == la then
        prefix + b[j:]
      else if j == lb then
        prefix + a[i:]
      else
        if cmp(a[i], b[j]) < 1 then
          aux(i + 1, j, prefix + [a[i]]) tailstrict
        else
          aux(i, j + 1, prefix + [b[j]]) tailstrict;
    aux(0, 0, []);

  local l = std.length(arr);
  local mid = std.floor(l / 2);
  local left = arr[:mid], right = arr[mid:];
  if mid == 0 then right else merge(sort(left), sort(right));

local divider1 = [[2]], divider2 = [[6]];
local sorted = sort(packets + [divider1, divider2]);
(std.find(divider1, sorted)[0] + 1) * (std.find(divider2, sorted)[0] + 1)
