local examples = [
  { msg: 'mjqjpqmgbljsphdztnvjfqwrcgsmlb', offset: 7 },
  { msg: 'bvwbjplbgvbhsrlpgdmjqwftvncz', offset: 5 },
  { msg: 'nppdvjthqldpwncqszvftbrmjlhg', offset: 6 },
  { msg: 'nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg', offset: 10 },
  { msg: 'zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw', offset: 11 },
];

local seqlen = 14;
local uniq(arr) = std.length(arr) == std.length(std.set(arr));
local findfirst(arr, x) = std.find(x, arr)[0];
local finduniqseq(arr, len) = [
  uniq(arr[offset:offset + len])
  for offset in std.range(0, std.length(arr) - len)
];

findfirst(finduniqseq(importstr 'input', seqlen), true) + seqlen
