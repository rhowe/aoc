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
	let inputLines = strings.Split(strings.TrimSpace(readInput.contents), "\n")

	// Split each line on spaces, discarding empty tokens
	// Parse strings into integers
	// Results in an array of pairs of numbers
	// e.g. [ [1,2], [1,3], ...]
	let parsedInput = [for line in inputLines {
		[for tok in strings.Split(line, " ")
			if tok != "" {strconv.ParseUint(tok, 10, 0)}]}]

	// Indexes into the input array
	let lineIndexes = list.Range(0, len(inputLines), 1)

	// Transpose the arrays
	// e.g. [ [1, 2], [3, 4], [5, 6] ]
	// becomes [ [ 1, 3, 5], [2, 4, 6] ]
	let transposedInput = [
		[for idx in lineIndexes {parsedInput[idx][0]}],
		[for idx in lineIndexes {parsedInput[idx][1]}],
	]

	// Sort each array
	let transposedInputSorted = [for i in transposedInput {list.Sort(i, list.Ascending)}]

	// Reverse the transposition
	// e.g. [ [ 1, 3, 5], [2, 4, 6] ]
	// becomes [ [1, 2], [3, 4], [5, 6] ]
	let pairs = [for idx in lineIndexes {
		[transposedInputSorted[0][idx], transposedInputSorted[1][idx]]
	}]

	// Calculate the difference within each pair
	let distances = [for idx in lineIndexes {
		let ordered = list.Sort(pairs[idx], list.Ascending)
		ordered[1] - ordered[0]
	}]

	// Sum the distances
	let sumDistances = list.Sum(distances)

	// Calculate the similarity scores
	let similarityScores = [
		for left in transposedInputSorted[0] {left * list.Sum([for right in transposedInputSorted[1] if left == right {1}])},
	]

	// Sum the similarity scores
	let sumSimilarities = list.Sum(similarityScores)

	// Profit
	echoResult: cli.Print & {
		text: "Part 1 Result: \(sumDistances)\nPart 2 Result: \(sumSimilarities)"
	}
}
