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
	let inputLines = strings.Split(readInput.contents, "\n")

	// Split each line on spaces
	let inputLinesTokenised = [for line in inputLines if line != "" {strings.Split(line, " ")}]

	// Parse strings into integers, discarding empty strings resulting from consecutive whitespace
	// Results in an array of pairs of numbers
	// e.g. [ [1,2], [1,3], ...]
	let parsedInput = [for line in inputLinesTokenised {[for n in line if n != "" {strconv.ParseUint(n, 10, 0)}]}]

	// Transpose the arrays
	// e.g. [ [1, 2], [3, 4], [5, 6] ]
	// becomes [ [ 1, 3, 5], [2, 4, 6] ]
	// Then sort each array
	let transposedInput = [
		list.Sort([for idx in list.Range(0, len(parsedInput), 1) {parsedInput[idx][0]}], list.Ascending),
		list.Sort([for idx in list.Range(0, len(parsedInput), 1) {parsedInput[idx][1]}], list.Ascending),
	]

	// Reverse the transposition
	// e.g. [ [ 1, 3, 5], [2, 4, 6] ]
	// becomes [ [1, 2], [3, 4], [5, 6] ]
	// then sort each pair (makes calculating the difference easier later)
	let orderedPairs = [for idx in list.Range(0, len(transposedInput[0]), 1) {
		list.Sort([transposedInput[0][idx], transposedInput[1][idx]], list.Ascending)
	}]

	// Calculate the difference within each pair
	let distances = [for idx in list.Range(0, len(orderedPairs), 1) {
		orderedPairs[idx][1] - orderedPairs[idx][0]
	}]

	// Sum the distances
	let sumDistances = list.Sum(distances)

	// Calculate the similarity scores
	let similarityScores = [
		for left in transposedInput[0] {left * list.Sum([for right in transposedInput[1] if left == right {1}])},
	]

	// Sum the similarity scores
	let sumSimilarities = list.Sum(similarityScores)

	// Profit
	echoResult: cli.Print & {
		text: "Part 1 Result: \(sumDistances)\nPart 2 Result: \(sumSimilarities)"
	}
}
