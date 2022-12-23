local debug = false;

local splitlines(str) = std.split(str, '\n');
local splitwords(str) = std.split(str, ' ');
local expand_command(step) = std.repeat([step[0]], std.parseInt(step[1]));
local commands = std.flatMap(expand_command, [
  splitwords(line)
  for line in splitlines(std.rstripChars(importstr 'input', '\n'))
]);

local adjacent(p1, p2) = std.abs(p1[0] - p2[0]) < 2 && std.abs(p1[1] - p2[1]) < 2;
local tailpos(head, tail) =
  if adjacent(head, tail) then tail
  else
    local drag =
      if head[0] == tail[0] || head[1] == tail[1]
      then function(h, t) t + ((h - t) / 2)
      else function(h, t) t + if h < t then -1 else if h == t then 0 else 1;

    [drag(head[0], tail[0]), drag(head[1], tail[1])]
;

std.length(std.set(std.foldl(
  function(state, cmd)
    local newHead = [
      state.rope[0][0] + { L: -1, R: 1, U: 0, D: 0 }[cmd],
      state.rope[0][1] + { L: 0, R: 0, U: 1, D: -1 }[cmd],
    ];
    local newRope = std.foldl(function(rope, knot)
                                rope + [tailpos(rope[std.length(rope) - 1], knot)],
                              state.rope[1:],
                              [newHead]);
    local newTail = newRope[std.length(newRope) - 1];
    local newState = state {
      rope: newRope,
      [if state.rope[std.length(state.rope) - 1] != newTail then 'tailVisits']: state.tailVisits + [newTail],
    };

    if debug
    then std.trace('rope=' + state.rope + ', cmd=' + cmd + ', newState=' + newState.rope, newState)
    else newState,
  commands,
  {
    rope: std.makeArray(10, function(x) [0, 0]),
    tailVisits: [[0, 0]],
  }
).tailVisits))
