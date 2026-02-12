package aoc2024day1

import "list"

import "math"

import "strconv"

import "strings"

import "tool/cli"

import "tool/file"

inputfile: *"input" | string @tag(input)

answer1: *int | int @tag(answer1, type=int)

answer2: *int | int @tag(answer2, type=int)

command: aocDay1: {
	// read input
	readInput: file.Read & {
		filename: inputfile
		contents: string
	}

	// Split the input on line breaks into an array of strings
	let inputLines = [...string] & strings.Split(strings.TrimSpace(readInput.contents), "\n")

	// The input is parsed into a list of pairs of strings
	#InputData: [...[string, string]]

	// Split each line on spaces
	let parsedInput = #InputData & [for line in inputLines {
		let tokens = strings.SplitN(line, " ", 2)
		[tokens[0], strings.TrimSpace(tokens[1])]
	}]

	// Transpose the arrays
	// e.g. [ [1, 2], [3, 4], [5, 6] ]
	// becomes [ [ 1, 3, 5], [2, 4, 6] ]
	let transposedInput = [[...string], [...string]] & [for idx in [0, 1] {
		[for pair in parsedInput {pair[idx]}]},
	]

	// Sort each array
	let transposedInputSorted = [[...string], [...string]] & [for i in transposedInput {
		list.Sort(i, list.Ascending)
	}]

	// Reverse the transposition
	// e.g. [ [ 1, 3, 5], [2, 4, 6] ]
	// becomes [ [1, 2], [3, 4], [5, 6] ]
	let pairs = [...[string, string]] & [for idx, left in transposedInputSorted[0] {
		let right = string & transposedInputSorted[1][idx]
		[left, right]
	}]

	// Calculate the difference within each pair
	let distances = [...(int & >=0)] & [for pair in pairs {
		math.Abs(strconv.ParseUint(pair[0], 10, 0) - strconv.ParseUint(pair[1], 10, 0))
	}]

	// Sum the distances
	let sumDistances = answer1 & list.Sum(distances)

	// A list of unique values in the left column
	let uniqueLeftValues = [...string] & {
		let leftList = [...string] & transposedInput[0]
		[for idx, left in leftList if !list.Contains(list.Drop(leftList, idx+1), left) {left}]
	}

	// Construct a map of values in the left list and their frequency in the right list
	let leftFreqInRight = {
		let rightList = [...string] & transposedInputSorted[1]
		for left in uniqueLeftValues {(left): len([for elem in rightList if elem == left {true}])}
	}

	// Calculate the similarity scores
	let similarityScores = [...int] & [
		for left in transposedInputSorted[0] {strconv.ParseUint(left, 10, 0) * leftFreqInRight[left]},
	]

	// Sum the similarity scores
	let sumSimilarities = answer2 & list.Sum(similarityScores)

	// Profit
	echoResult: cli.Print & {
		text: "Part 1 Result: \(sumDistances)\nPart 2 Result: \(sumSimilarities)"
	}
}
