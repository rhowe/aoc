local input = [
  std.stringChars(line)
  for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
];

local delimiters = {
  '(': ')',
  '[': ']',
  '{': '}',
  '<': '>',
};

local openings = std.set(std.objectFields(delimiters));
local closings = std.set(std.objectValues(delimiters));

local scores = {
  ')': 1,
  ']': 2,
  '}': 3,
  '>': 4,
};

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

local push = function(stack, x) std.join([], [[x], stack]);
local pop  = function(stack) [stack[0], stack[1:std.length(stack)]];

local stack = [];

local parsechar = function(parser, ch)
  if parser[1] != null
  then parser
  else if std.member(openings, ch)
  then [push(parser[0], ch), null]
  else if std.length(parser[0]) > 0
  then
  local res = pop(parser[0]);
  if ch == delimiters[res[0]]
  then [res[1], null]
  else [parser[0], 'Expected ' + delimiters[res[0]] + ', but found ' + ch + ' instead', scores[ch]];

local parsed = [
  std.foldl(parsechar, line, [[], null])
  for line in input
];

local results = std.sort(
[
  std.foldl(function(score, x) score * 5 + x, std.map(function(ch) scores[delimiters[ch]], valid[0]), 0)
  for valid in parsed
  if valid[1] == null
]);

results[(std.length(results) - 1) / 2]
