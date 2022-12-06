local examples = [
  { msg: 'mjqjpqmgbljsphdztnvjfqwrcgsmlb', offset: 7 },
  { msg: 'bvwbjplbgvbhsrlpgdmjqwftvncz', offset: 5 },
  { msg: 'nppdvjthqldpwncqszvftbrmjlhg', offset: 6 },
  { msg: 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg', offset: 10 },
  { msg: 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw', offset: 11 },
];

local uniq = function(arr) std.length(arr) == std.length(std.set(arr));
local finduniqseq = function(arr, n) [
  uniq(arr[offset:offset + n])
  for offset in std.range(0, std.length(arr) - n)
];

std.find(true, finduniqseq(std.rstripChars(importstr 'input', '\n'), 4))[0] + 4
