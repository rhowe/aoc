// Run this as: jsonnet -S 10part2.jsonnet

local debug = false;

local program = [
  std.split(line, ' ')
  for line in std.split(std.rstripChars(importstr 'input', '\n'), '\n')
];

local crt = {
  clk: 0,
  X: 1,
  pixels: [],
  tick()::
    local clk = if debug then std.trace('' + self, self.clk) else self.clk;
    local col = clk % 40;
    local row = std.floor(clk / 40);
    local draw = std.abs(self.X - col) <= 1;

    self {
      clk: clk + 1,
      [if draw then 'pixels']+: [[col, row]],
    },
  noop():: self.tick(),
  addx(val)::
    local X = self.X;

    self.tick().tick() {
      X: X + val,
    },
  exec(instr)::
    local oldclk = self.clk;
    local verb = if debug then std.trace('instr=' + instr, instr[0]) else instr[0];
    local newcrt =
      if verb == 'noop'
      then self.noop()
      else self.addx(std.parseInt(instr[1]));

    newcrt,
  run(instrs)::
    std.foldl(function(x, instr) x.exec(instr), instrs, self),
  prtscr()::
    std.join('\n', [
      std.join('', [
        if std.member(self.pixels, [col, row]) then 'X' else ' '
        for col in std.range(0, 39)
      ])
      for row in std.range(0, 5)
    ]),
};

crt.run(program).prtscr()
