package day1

start_position = 50

direction_map := {
  "L": -1,
  "R": 1
}

# Multiplier for direction - left is negative, right is positive
multiplier(instruction) := direction_map[substring(instruction, 0, 1)]

# Extract the distance to turn from an instruction, e.g. L35 => 35
distance(instruction) := to_number(trim_left(instruction, "RL"))

# Calculate an array representing the dial motions
turns := [dir|
  instruction := input[_]
  dir := multiplier(instruction) * distance(instruction)
]

# Calculate the resulting position of each turn
# The position is the starting position plus the sum of all turns to that point
# We sort of cheat because turns anticlockwise result in negative numbers but that's fine.
turn_positions[turn] := position if {
  some turn, value in turns
  position := (start_position + sum(array.slice(turns, 0, turn+1))) % 100
}

# Find the indexes of the turns which resulted in the dial at 0
zero_turns contains turn if {
  some turn, pos in turn_positions
  pos == 0
}

# Count how many turns had a zero position
zeros := count(zero_turns)
