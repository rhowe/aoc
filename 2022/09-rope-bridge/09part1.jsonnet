local debug = false;

local splitlines(str) = std.split(str, '\n');
local splitwords(str) = std.split(str, ' ');
local expand_command(step) = std.repeat([step[0]], std.parseInt(step[1]));
local commands = std.flatMap(expand_command, [
  splitwords(line)
  for line in splitlines(std.rstripChars(importstr 'input', '\n'))
]);

local adjacent(p1, p2) = std.abs(p1[0] - p2[0]) < 2 && std.abs(p1[1] - p2[1]) < 2;

std.length(std.set(std.foldl(
  function(state, cmd)
    local newHead = [
      state.head[0] + { L: -1, R: 1, U: 0, D: 0 }[cmd],
      state.head[1] + { L: 0, R: 0, U: 1, D: -1 }[cmd],
    ];
    local moveTail = !adjacent(newHead, state.tail);
    local newTail = state.head;
    local newState = state {
      head: newHead,
      [if moveTail then 'tail']: newTail,
      [if moveTail then 'tailVisits']: state.tailVisits + [newTail],
    };

    if debug
    then std.trace('state=' + state.head + state.tail + ', cmd=' + cmd + ', newState=' + newState.head + newState.tail + ',moveTail=' + moveTail, newState)
    else newState,
  commands,
  {
    head: [0, 0],
    tail: [0, 0],
    tailVisits: [[0, 0]],
  }
).tailVisits))
