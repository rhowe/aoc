local debug = false;

local input = [
  [
    std.parseInt(ch)
    for ch in std.stringChars(line)
  ]
  for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
];

local width = std.length(input[0]);
local height = std.length(input);

local sum(a, b) = a + b;
local sumarray(arr) = std.foldl(sum, arr, 0);
local arraymax(arr) = std.foldl(std.max, arr, 0);

local mapWithIndex2d(func, arr) = std.mapWithIndex(
  function(y, row)
    std.mapWithIndex(
      function(x, elem)
        func(x, y, elem), row
    ),
  arr
);

local findfirst(arr, cond, idx=0) =
  local len = std.length(arr);
  if len == 0 then -1
  else if cond(arr[0]) then idx
  else findfirst(arr[1:len], cond, idx + 1);

local scenicscore(x, y, grid, w, h) =
  local elem = grid[y][x];
  local row = grid[y];
  local col = [r[x] for r in grid];
  local cond(x) = x >= elem;
  local view_l = findfirst(std.reverse(row[0:x]), cond);
  local view_r = findfirst(row[x + 1:w], cond);
  local view_u = findfirst(std.reverse(col[0:y]), cond);
  local view_d = findfirst(col[y + 1:height], cond);
  local score =
    (if view_l == -1 then x else (view_l + 1))
    * (if view_r == -1 then width - x - 1 else (view_r + 1))
    * (if view_u == -1 then y else (view_u + 1))
    * (if view_d == -1 then height - y - 1 else (view_d + 1));

  if debug
  then std.trace('[' + x + ',' + y + '] elem=' + elem
                 + ',view_l=' + view_l + ',view_r=' + view_r
                 + ',view_u=' + view_u + ',view_d=' + view_d
                 + ',score=' + score, score)
  else score
;

local print(grid) = std.join('\n', [
  std.join(',', [
    std.toString(cell)
    for cell in row
  ])
  for row in grid
]);

local views = mapWithIndex2d(function(x, y, elem)
  if x == 0 || y == 0 || x == width - 1 || y == height - 1 then 0
  else scenicscore(x, y, input, width, height), input);

arraymax([
  arraymax(row)
  for row in views
])
//print(
//  [
//    row
//    for row in
//      highest
//  ]
//)
