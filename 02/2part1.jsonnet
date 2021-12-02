# Needs a big stack - run with jsonnet -s 10000
local input = std.map(function(x) std.split(x, ' '), std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

local move(pos, cmd) =
  local dir = cmd[0];
  local dist = std.parseInt(cmd[1]);
  if dir == 'forward' then { x: pos.x + dist, y: pos.y        } else
  if dir == 'up' then      { x: pos.x       , y: pos.y - dist } else
  if dir == 'down' then    { x: pos.x       , y: pos.y + dist }
;
local end = std.foldl(move, input, {x:0,y:0});

end.x * end.y
