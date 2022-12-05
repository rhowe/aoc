local input = std.rstripChars(importstr 'eg', '\n');

local lines = std.split(input, '\n');
local is_not_space = function(x) x != ' ';

local parsemove = function(move)
  local words = std.split(move, ' ');
  {
    from: words[3],
    to: words[5],
    qty: std.parseInt(words[1]),
  };

{
  moves: [
    parsemove(line)
    for line in lines
    if std.length(line) > 0 && line[0] == 'm'
  ],
  stacks:
    local rows = [
      line
      for line in lines
      if std.length(line) > 0 && line[0] != 'm'
    ];
    local n_rows = std.length(rows);

    [
      std.filter(is_not_space, [
        row[col * 4 + 1]
        for row in rows[0:n_rows - 1]
      ])
      for col in std.range(0, std.length(rows[n_rows - 1]) / 4)
    ],
  get_message:: function()
    std.join('', [stack[0] for stack in self.stacks]),
}.get_message()
