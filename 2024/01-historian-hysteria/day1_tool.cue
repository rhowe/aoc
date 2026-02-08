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
	let parsedInput = [...[int, int]] & [for line in inputLines {
		[for tok in strings.Split(line, " ")
			if tok != "" {strconv.ParseUint(tok, 10, 0)}]}]

	// Transpose the arrays
	// e.g. [ [1, 2], [3, 4], [5, 6] ]
	// becomes [ [ 1, 3, 5], [2, 4, 6] ]
	let transposedInput = [[...int], [...int]] & [
		[for pair in parsedInput {pair[0]}],
		[for pair in parsedInput {pair[1]}],
	]

	// Sort each array
	let transposedInputSorted = [[...int], [...int]] & [for i in transposedInput {list.Sort(i, list.Ascending)}]

	// Reverse the transposition
	// e.g. [ [ 1, 3, 5], [2, 4, 6] ]
	// becomes [ [1, 2], [3, 4], [5, 6] ]
	let pairs = [...[int, int]] & [for idx, left in transposedInputSorted[0] {
		let right = int & transposedInputSorted[1][idx]
		[left, right]
	}]

	// Calculate the difference within each pair
	let distances = [...int] & [for pair in pairs {
		let ordered = [int, int] & list.Sort(pair, list.Ascending)
		ordered[1] - ordered[0]
	}]

	// Sum the distances
	let sumDistances = int & list.Sum(distances)

	// A list of unique values in the left column
	let uniqueLeftValues = [...int] & {
		let leftList = [...int] & transposedInputSorted[0]
		[for idx, left in leftList if !list.Contains(list.Drop(leftList, idx+1), left) {left}]
	}

	// Construct a map of values in the left list and their frequency in the right list
	// Keys have to be strings, somewhat annoyingly
	let leftFreqInRight = {
		let rightList = [...int] & transposedInputSorted[1]
		for left in uniqueLeftValues {(strconv.FormatInt(left, 10)): len([for elem in rightList if elem == left {true}])}
	}

	// Calculate the similarity scores
	let similarityScores = [...int] & [
		for left in transposedInputSorted[0] {left * leftFreqInRight[strconv.FormatInt(left, 10)]},
	]

	// Sum the similarity scores
	let sumSimilarities = int & list.Sum(similarityScores)

	// Profit
	echoResult: cli.Print & {
		text: "Part 1 Result: \(sumDistances)\nPart 2 Result: \(sumSimilarities)"
	}
}
