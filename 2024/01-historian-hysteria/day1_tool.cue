package aoc2024day1

import "list"

import "strconv"

import "strings"

import "tool/cli"

import "tool/file"

inputfile: *"input" | string @tag(input)

command: aocDay1: {
	// read input
	readInput: file.Read & {
		filename: inputfile
		contents: string
	}

	// Split the input on line breaks into an array of strings
	let inputLines = [...string] & strings.Split(strings.TrimSpace(readInput.contents), "\n")

	// Split each line on spaces, discarding empty tokens
	// Parse strings into integers
	// Results in an array of pairs of numbers
	// e.g. [ [1,2], [1,3], ...]
	let parsedInput = [...[string, string]] & [for line in inputLines {
		[for tok in strings.SplitN(line, " ", 2)
			{strings.TrimSpace(tok)}]}]

	// Transpose the arrays
	// e.g. [ [1, 2], [3, 4], [5, 6] ]
	// becomes [ [ 1, 3, 5], [2, 4, 6] ]
	let transposedInput = [[...string], [...string]] & [
		[for pair in parsedInput {pair[0]}],
		[for pair in parsedInput {pair[1]}],
	]

	// Sort each array
	let transposedInputSorted = [[...string], [...string]] & [for i in transposedInput {list.Sort(i, list.Ascending)}]

	// Reverse the transposition
	// e.g. [ [ 1, 3, 5], [2, 4, 6] ]
	// becomes [ [1, 2], [3, 4], [5, 6] ]
	let pairs = [...[string, string]] & [for idx, left in transposedInputSorted[0] {
		let right = string & transposedInputSorted[1][idx]
		[left, right]
	}]

	// Calculate the difference within each pair
	let distances = [...int] & [for pair in pairs {
		let ordered = [int, int] & list.Sort([for elem in pair {strconv.ParseUint(elem, 10, 0)}], list.Ascending)
		ordered[1] - ordered[0]
	}]

	// Sum the distances
	let sumDistances = int & list.Sum(distances)

	// A list of unique values in the left column
	let uniqueLeftValues = [...string] & {
		let leftList = [...string] & transposedInputSorted[0]
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
	let sumSimilarities = int & list.Sum(similarityScores)

	// Profit
	echoResult: cli.Print & {
		text: "Part 1 Result: \(sumDistances)\nPart 2 Result: \(sumSimilarities)"
	}
}
