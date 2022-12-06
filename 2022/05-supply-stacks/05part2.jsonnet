local input = std.split(std.strReplace(std.rstripChars(importstr 'input', '\n'), '\n\n', '^'), '^');

local is_not_space(char) = char != ' ';

local stack = {
  items: [],
  pop(x)::
    local s = self;
    {
      values: s.items[0:x],
      stack: s {
        items: s.items[x:],
      },
    },
  push(x)::
    local curr = self.items;
    self {
      items: x + curr,
    },
};

local parsemove(move) =
  local words = std.split(move, ' ');
  {
    from: words[3],
    to: words[5],
    qty: std.parseInt(words[1]),
  };

local parsestacks(str) =
  local rows = std.split(str, '\n');
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
  };

{
  stacks: parsestacks(input[0]),
  move(qty, from, to)::
    local src = self.stacks[from].pop(qty);
    local dest = self.stacks[to].push(src.values);
    self {
      stacks+: {
        [from]: src.stack,
        [to]: dest,
      },
    },
  do_moves(moves)::
    std.foldl(function(machine, m) machine.move(m.qty, m.from, m.to), moves, self),
  get_message()::
    std.join('', [
      self.stacks[stack].pop(1).values[0]
      for stack in std.set(std.objectFields(self.stacks))
    ]),
}
.do_moves(std.map(parsemove, std.split(input[1], '\n')))
.get_message()
