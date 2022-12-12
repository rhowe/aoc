local debug = false;

local splitlines(str) = std.split(str, '\n');
local splitwords(str) = std.split(str, ' ');
local sum(a, b) = a + b;
local sumarray(arr) = std.foldl(sum, arr, 0);

local program = [
  splitwords(line)
  for line in splitlines(std.rstripChars(importstr 'input', '\n'))
];

local crt = {
  clk: 0,
  X: 1,
  strengths: [],
  signalstrength():: self.clk * self.X,
  tick()::
    local clk = self.clk;

    local newcrt = self {
      clk: clk + 1,
    };

    if std.member([20, 60, 100, 140, 180, 220], newcrt.clk)
    then
      newcrt {
        strengths+: [newcrt.signalstrength()],
      }
    else newcrt,
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
};

sumarray(std.foldl(function(x, instr) x.exec(instr), program, crt).strengths)
