local input = std.rstripChars(importstr 'input', '\n');

local debug = false;

local tok = {
  A: '🪨',
  B: '🧻',
  C: '✂️',
  X: '👎',
  Y: '😐',
  Z: '👍',
};

local values = {
  '🪨': 1,
  '🧻': 2,
  '✂️': 3,
};

local required_move = {
  '🪨😐': '🪨',
  '🧻😐': '🧻',
  '✂️😐': '✂️',
  '🪨👎': '✂️',
  '🪨👍': '🧻',
  '🧻👍': '✂️',
  '🧻👎': '🪨',
  '✂️👎': '🧻',
  '✂️👍': '🪨',
};

local bonus = {
  '👎': 0,
  '😐': 3,
  '👍': 6,
};

local sum = function(a, b) a + b;
local sumarray = function(arr) std.foldl(sum, arr, 0);
local splitlines = function(str) std.split(str, '\n');
local splitwords = function(str) std.split(str, ' ');
local lex = function(arr) [tok[move] for move in arr];
local parselines = function(lines) [lex(splitwords(line)) for line in lines];

local play = function(arr)
  local them = arr[0];
  local result = arr[1];
  local us = required_move[them + result];
  local total = values[us] + bonus[result];
  if debug then
    std.trace('They played ' + them + ' so we play ' + us + ' so that we ' + result + ' for a score of ' + total, total)
  else total;

sumarray([play(round) for round in parselines(splitlines(input))])
