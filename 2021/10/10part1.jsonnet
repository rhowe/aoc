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

local scores = {
  ')': 3,
  ']': 57,
  '}': 1197,
  '>': 25137,
};

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

local push = function(stack, x) std.join([], [[x], stack]);
local pop  = function(stack) [stack[0], stack[1:std.length(stack)]];

local parsechar = function(parser, ch)
  if parser[1] != null
  then parser
  else if std.member(openings, ch)
  then [push(parser[0], ch), null, parser[2]]
  else if std.length(parser[0]) > 0
  then
  local res = pop(parser[0]);
  if ch == delimiters[res[0]]
  then [res[1], null, parser[2]]
  else [parser[0], 'Expected ' + delimiters[res[0]] + ', but found ' + ch + ' instead', scores[ch]];

sumarray(
[
  std.foldl(parsechar, line, [[], null, 0])[2]
  for line in input
]
)
