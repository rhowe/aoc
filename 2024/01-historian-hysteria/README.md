# Advent of Code 2024 day 1 in CUE

To run the code:

    cue cmd aocDay1

This expects the puzzle input to be in a file called `input` in the same directory.

To supply alternative input:

    cue cmd --inject input=alternative-filename aocDay1

You can also supply the expected results and an error will be thrown if the
calculation results differ.

    cue cmd --inject input=example-input --inject answer1=11 --inject answer2=31 aocDay1
