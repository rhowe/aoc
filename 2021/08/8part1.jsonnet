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

std.length([
  true
  for i in input
  for disp in i.disp
  if std.member([2, 3, 4, 7], std.length(disp))
])
