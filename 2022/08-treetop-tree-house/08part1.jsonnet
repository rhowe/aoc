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

local visible(x, y, grid, w, h) =
  local elem = grid[y][x];
  local row = grid[y];
  local col = [r[x] for r in grid];
  local max_l = if x == 0 then -1 else arraymax(row[0:x]);
  local max_r = if x == width - 1 then -1 else arraymax(row[x + 1:w]);
  local max_u = if y == 0 then -1 else arraymax(col[0:y]);
  local max_d = if y == height - 1 then -1 else arraymax(col[y + 1:height]);
  local visible = elem > std.min(std.min(max_l, max_r), std.min(max_u, max_d));

  if debug
  then std.trace('[' + x + ',' + y + '] elem=' + elem
                 + ',max_l=' + max_l + ',max_r=' + max_r
                 + ',max_u=' + max_u + ',max_d=' + max_d
                 + ',visible=' + visible, visible)
  else visible
;

local print(grid) = std.join('\n', [
  std.join('', [
    if cell then '.' else ' '
    for cell in row
  ])
  for row in grid
]);

local highest =
  std.mapWithIndex(function(y, row)
    std.mapWithIndex(function(x, elem) visible(x, y, input, width, height), row)
                   , input);

sumarray([
  std.count(row, true)
  for row in highest
])
//print(
//  [
//    row
//    for row in
//      highest
//  ]
//)
