local input = std.rstripChars(importstr 'input', '\n');

local debug = true;

local sumarray = function(arr)
  local sum = function(a, b) a + b;

  std.foldl(sum, arr, 0);

local parse = function(input)
  [
    local words = std.split(line, ' ');
    local tokens = {
      A: '💩',
      B: '🧻',
      C: '✂️',
      X: '👎',
      Y: '😐',
      Z: '👍',
    };

    {
      them: tokens[words[0]],
      result: tokens[words[1]],
    }
    for line in std.split(input, '\n')
  ];

local values = { '💩': 1, '🧻': 2, '✂️': 3 };
local bonus = { '👎': 0, '😐': 3, '👍': 6 };

local required_move = {
  '💩😐': '💩',
  '🧻😐': '🧻',
  '✂️😐': '✂️',
  '💩👎': '✂️',
  '💩👍': '🧻',
  '🧻👍': '✂️',
  '🧻👎': '💩',
  '✂️👎': '🧻',
  '✂️👍': '💩',
};

local play = function(game)
  local us = required_move[game.them + game.result];
  local total = values[us] + bonus[game.result];

  if debug then
    std.trace('They played ' + game.them + ' so we play ' + us + ' so that we ' + game.result + ' for a score of ' + total, total)
  else total;

sumarray([play(round) for round in parse(input)])
