local input = std.split(std.rstripChars(importstr 'input', '\n'), '\n');

local calls = [
  std.parseInt(n)
  for n in std.split(input[0], ',')
];

local callouts = [
  std.sort(calls[0:n:1])
  for n in std.range(5, std.length(calls) - 6)
];

local all_cards = [
  [
    [
      std.parseInt(std.lstripChars(std.substr(row, n * 3, 2), ' '))
      for n in std.range(0, std.length(row) / 3)
    ]
    for row in card
  ]
  for card in [
    input[2+(index * 6):7+(index * 6):1]
    for index in std.range(0, std.length(input) / 6 - 1)
  ]
];

local cards_with_winning_lines = [
  [card,
  [ # winning rows
    std.sort(row)
	   for row in card
  ] + [ # winning columns
    std.sort([
      row[col]
      for row in card
    ])
    for col in std.range(0, std.length(card[0]) - 1)
  ]]
  for card in all_cards
];

local has = function(condition, arr) std.foldl(function(found, e) if found then found else condition(e), arr, false);
local is_winning_line = function(line, call) std.length(std.setInter(line, call)) == std.length(line);
local is_winner = function(card, call) has(function(x) is_winning_line(x, call), card[1]);

local final_card_to_win = std.foldl(function(cards, call)
  if std.length(cards) == 1 then cards
  else std.filter(function(card) !is_winner(card, call), cards),
  callouts,
  cards_with_winning_lines)[0];

local first_winning_call = std.filter(function(call) is_winner(final_card_to_win, call), callouts)[0];

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

sumarray(std.setDiff(std.sort(std.flattenArrays(final_card_to_win[0])), first_winning_call)) * calls[std.length(first_winning_call) - 1]
