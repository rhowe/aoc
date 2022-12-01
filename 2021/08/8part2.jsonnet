local digits = {
  "cf": 1,
  "acf": 7,
  "bcdf": 4,
  "acdeg": 2,
  "acdfg": 3,
  "abdfg": 5,
  "abcefg": 0,
  "abdefg": 6,
  "abcdfg": 9,
  "abcdefg": 8,
};

local input = [
  local part = std.split(line, '|');
  {
    eg: [
      std.sort(std.stringChars(eg))
      for eg in std.split(std.rstripChars(part[0], ' '), ' ')
    ],
    disp: [
      std.sort(std.stringChars(disp))
      for disp in std.split(std.lstripChars(part[1], ' '), ' ')
    ],
  }
  for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
];

local one   = function(examples) [ eg for eg in examples if std.length(eg) == 2 ][0];
local four  = function(examples) [ eg for eg in examples if std.length(eg) == 4 ][0];
local seven = function(examples) [ eg for eg in examples if std.length(eg) == 3 ][0];
local eight = function(examples) [ eg for eg in examples if std.length(eg) == 7 ][0];

local a = function(examples, nums)
  std.setDiff(nums.seven, nums.one)[0]
;

local g = function(examples, nums)
  local four_plus_a = std.setUnion(nums.four, [a(examples, nums)]);
  [
    std.setDiff(eg, four_plus_a)[0]
    for eg in examples if std.length(eg) == 5 && std.length(std.setDiff(eg, four_plus_a)) == 1
  ][0]
;

local d = function(examples, nums)
  local seven_plus_g = std.setUnion(nums.seven, [g(examples, nums)]);
  [
    std.setDiff(eg, seven_plus_g)[0]
    for eg in examples if std.length(eg) == 5 && std.length(std.setDiff(eg, seven_plus_g)) == 1
  ][0]
;

local b = function(examples, nums)
  local seven_plus_d = [ std.setUnion(nums.seven, [d(examples, nums)]) ][0];
  std.setDiff(nums.four, seven_plus_d)[0]
;

local e = function(examples, nums)
  local four_plus_ag = std.setUnion(nums.four, std.set([a(examples, nums), g(examples, nums)]));
  std.setDiff(nums.eight, four_plus_ag)[0]
;

local f = function(examples, nums)
  local abdg = std.set([a(examples, nums), b(examples, nums), d(examples, nums), g(examples, nums)]);
  [
    std.setDiff(eg, abdg)[0]
    for eg in examples if std.length(eg) == 5 && std.length(std.setDiff(eg, abdg)) == 1
  ][0]
;

local c = function(examples, nums)
  std.setDiff(nums.one, [f(examples, nums)])[0]
;

local translate_digit = function(wiremap, digit)
  std.join('', std.sort(std.map(function(x) wiremap[x], digit)))
;

local sumarray = function(arr) std.foldl(function(x, e) x + e, arr, 0);

sumarray([
  x.mapped_disp[0] * 1000 + x.mapped_disp[1] * 100 + x.mapped_disp[2] * 10 + x.mapped_disp[3]
  for x in [
    {
      eg:: i.eg,
      nums:: {
        one: one(i.eg),
        four: four(i.eg),
        seven: seven(i.eg),
        eight: eight(i.eg),
      },
      wiremap:: {
        [a(i.eg, self.nums)]: "a",
        [b(i.eg, self.nums)]: "b",
        [c(i.eg, self.nums)]: "c",
        [d(i.eg, self.nums)]: "d",
        [e(i.eg, self.nums)]: "e",
        [f(i.eg, self.nums)]: "f",
        [g(i.eg, self.nums)]: "g",
      },
      disp:: i.disp,
      mapped_disp: [
        digits[translate_digit(self.wiremap, d)]
        for d in i.disp
      ],
    }
    for i in input
  ]
])
