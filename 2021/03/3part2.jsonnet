local input = std.map(function(x) std.map(function(x) x == '1', std.stringChars(x)), std.split(std.rstripChars(importstr 'input', '\n'), '\n'));

local o2filter =
	function(arr, idx)
	local i = local focus = std.map(function(x) x[idx], arr);
	std.find(std.count(focus, true) >= std.length(arr) / 2, focus);
	std.makeArray(std.length(i), function(ix) arr[i[ix]]);

local co2filter =
	function(arr, idx)
	local i = local focus = std.map(function(x) x[idx], arr);
	std.find(std.count(focus, false) > std.length(arr) / 2, focus);
	std.makeArray(std.length(i), function(ix) arr[i[ix]]);

local o2calc = function(arr, idx)  local res = o2filter(arr, idx);  if std.length(res) == 1 then res else o2calc(res, idx+1);
local co2calc = function(arr, idx) local res = co2filter(arr, idx); if std.length(res) == 1 then res else co2calc(res, idx+1);

local sum(arr) = std.foldl(function(total, x) total + x, arr, 0);

local binarr2dec = function(arr) sum(std.mapWithIndex(function (idx, e) if e then std.pow(2, idx) else 0, std.reverse(arr)));

binarr2dec(o2calc(input, 0)[0]) * binarr2dec(co2calc(input, 0)[0])
