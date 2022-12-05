local input = std.rstripChars(importstr 'input', '\n');

local lines = std.split(input, '\n');
local is_not_space = function(x) x != ' ';

local parsemove = function(move)
  local words = std.split(move, ' ');
  {
    from: words[3],
    to: words[5],
    qty: std.parseInt(words[1]),
  };

local stack = {
  items: [],
  pop:: function(x)
    local s = self;
    {
      values: s.items[0:x],
      stack: s {
        items: s.items[x:],
      },
    },
  push:: function(x)
    local curr = self.items;
    self {
      items: x + curr,
    },
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

    {
      [std.toString(col + 1)]:
        stack {
          items:
            std.filter(is_not_space, [
              row[col * 4 + 1]
              for row in rows[0:n_rows - 1]
            ]),
        }
      for col in std.range(0, std.length(rows[n_rows - 1]) / 4)
    },
  move(qty, from, to)::
    local src = self.stacks[from].pop(qty);
    local dest = self.stacks[to].push(src.values);
    self {
      stacks+: {
        [from]: src.stack,
        [to]: dest,
      },
    },
  do_moves()::
    std.foldl(function(acc, m) acc.move(m.qty, m.from, m.to), self.moves, self),
  get_message:: function()
    std.join('', [self.stacks[stack].pop(1).values[0] for stack in std.set(std.objectFields(self.stacks))]),
}.do_moves().get_message()
