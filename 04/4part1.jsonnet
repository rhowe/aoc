local input = std.split(std.rstripChars(importstr 'input', '\n'), '\n');

local calls = [
  std.parseInt(n)
  for n in std.split(input[0], ',')
];

local callouts = [
  std.sort(calls[0:n:1])
  for n in std.range(5, std.length(calls) - 6)
];

local cards = [
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

local cardwins = [
  [ # winning rows
    std.sort(row)
	   for row in card
  ] + [ # winning columns
    std.sort([
      row[col]
      for row in card
    ])
    for col in std.range(0, std.length(card[0]) - 1)
  ]
  for card in cards
];

local winninglines = function(card, call) std.filter(function(line) std.length(std.setInter(line, call)) == std.length(line), card);

local bingos = [
    [
      winninglines(card, call)
      for card in cardwins
    ]
    for call in callouts
  ];

local index_of_first_non_empty_array = function(arr, idx) if arr[idx] == [] then index_of_first_non_empty_array(arr, idx+1) else idx;

local find_first_bingo = function(n_call) local res = [
    winninglines(card, callouts[n_call])
    for card in cardwins
  ];
  if std.prune(res) == [] then
    find_first_bingo(n_call + 1)
  else
    {
      call: callouts[n_call],
      winning_card: cards[index_of_first_non_empty_array(res, 0)],
    };

local win = find_first_bingo(0);

local winning_card_nums = std.sort(std.flattenArrays(win.winning_card));
local unmarked_card_nums = std.setDiff(winning_card_nums, win.call);

local last_call = calls[std.length(win.call) - 1];

std.foldl(function(a, b) a + b, unmarked_card_nums, 0) * last_call
