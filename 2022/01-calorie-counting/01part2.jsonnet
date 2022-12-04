local str_list_to_intarray = function(x) std.map(std.parseInt, std.split(x, '\n'));
local neg = function(x) -x;
local sum = function(a, b) a + b;
local array_sum = function(arr) std.foldl(sum, arr, 0);
local array_max = function(arr) std.foldl(std.max, arr, 0);
local sum_inner_arrays = function(arr) std.map(array_sum, arr);

local chunkedinput = std.map(str_list_to_intarray, std.split(std.strReplace(std.rstripChars(importstr 'input', '\n'), '\n\n', '-'), '-'));

array_sum(std.sort(sum_inner_arrays(chunkedinput), neg)[0:3])
