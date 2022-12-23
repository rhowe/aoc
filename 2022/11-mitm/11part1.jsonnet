local opfunc(op) =
  if op[0] == '+'
  then function(old) old + if op[2:] == 'old' then old else std.parseInt(op[2:])
  else function(old) old * if op[2:] == 'old' then old else std.parseInt(op[2:])
;

local monkey = {
  new(id, str)::
    local stripPrefix(str, prefix) = str[std.length(prefix):std.length(str)];
    local parseStartingItems(str) = [
      std.parseInt(item)
      for item in std.split(std.strReplace(str[18:std.length(str)], ' ', ''), ',')
    ];
    local parseOperation(str) = str[13 + 6 + 4:std.length(str)];
    local parseTest(str) = std.parseInt(stripPrefix(str, '  Test: divisible by '));
    local parseTrue(str) = std.parseInt(stripPrefix(str, '    If true: throw to monkey '));
    local parseFalse(str) = std.parseInt(stripPrefix(str, '    If false: throw to monkey '));

    local lines = [line for line in std.split(str, '\n')];
    local items = parseStartingItems([
      line
      for line in lines
      if std.startsWith(line, '  Starting items:')
    ][0]);
    local op = opfunc(parseOperation([
      line
      for line in lines
      if std.startsWith(line, '  Operation:')
    ][0]));
    local test = parseTest([
      line
      for line in lines
      if std.startsWith(line, '  Test:')
    ][0]);
    local whenTrue = parseTrue([
      line
      for line in lines
      if std.startsWith(line, '    If true:')
    ][0]);
    local whenFalse = parseFalse([
      line
      for line in lines
      if std.startsWith(line, '    If false:')
    ][0]);

    monkey {
      id: id,
      lines:: lines,
      items: items,
      op:: op,
      test: test,
      whenTrue: whenTrue,
      whenFalse: whenFalse,
      inspections: 0,
    },

  inspect()::
    local m = self;

    {
      m: m {
        items: [],
        inspections: m.inspections + std.length(m.items),
      },
      throws: [
        local worry = std.floor(m.op(item) / 3);
        {
          worry: worry,
          dest: if worry % m.test == 0 then m.whenTrue else m.whenFalse,
        }
        for item in m.items
      ],
    },

  receive(items)::
    self {
      items+: [
        item.worry
        for item in items
        if item.dest == self.id
      ],
    },
};

local arrayreplace(arr, idx, elem) =
  std.makeArray(std.length(arr), function(i) if i == idx then elem else arr[i]);

local troop = std.mapWithIndex(
  monkey.new,
  std.split(std.strReplace(std.rstripChars(importstr 'input', '\n'), '\n\n', '^'), '^')
);

local inspectAndThrow(idx, all) =
  local throws = all[idx].inspect();

  [
    m.receive(throws.throws)
    for m in arrayreplace(all, idx, throws.m)
  ];

local round(all, idx=0) =
  if idx == std.length(all)
  then all
  else round(inspectAndThrow(idx, all), idx + 1);

local monkeysee = std.sort([
  m.inspections
  for m in std.foldl(function(t, x) round(t), std.range(0, 19), troop)
], function(x) -x);

monkeysee[0] * monkeysee[1]
