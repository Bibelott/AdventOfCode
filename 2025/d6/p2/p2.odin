package p2

import "core:bytes"
import "core:fmt"
import "core:time"

ROWS :: 4

part2 :: proc() {
	data := #load("../input")

	line_width := bytes.index(data, {'\n'})

	number_array := make([][ROWS]i8, line_width) // column-major

	total: u64 = 0

	column := 0
	row := 0


	line: []byte

	number_loop: for line_iter in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1
		line = line_iter

		if row == ROWS {
			break
		}

		column = 0

		for digit in line {
			defer column += 1

			number: i8
			if digit == ' ' {
				number = -1
			} else {
				number = i8(digit - '0')
			}

			number_array[column][row] = number
		}
	}

	column = 0
	next_problem_index := 0
	problem := 0

	operator: byte

	// fmt.println(number_array[:][:])

	sum :: proc(a: u64, b: u64) -> u64 {
		return a + b
	}

	product :: proc(a: u64, b: u64) -> u64 {
		return a * b
	}

	for next_problem_index < line_width {
		defer problem += 1

		operator = line[next_problem_index]

		column = next_problem_index

		result: u64
		operation: proc(_: u64, _: u64) -> u64

		if operator == '+' {
			result = 0
			operation = sum
		} else {
			result = 1
			operation = product
		}

		index_add := bytes.index_any(line[next_problem_index + 1:], {'+', '*'})

		if index_add == -1 {
			next_problem_index = line_width
		} else {
			next_problem_index += index_add
		}

		next_problem_index += 1

		for ; column < next_problem_index - 1; column += 1 {
			// fmt.println(column)
			number: u64 = 0
			for digit_index := 0; digit_index < ROWS; digit_index += 1 {
				if number_array[column][digit_index] == -1 {
					continue
				}
				number *= 10
				number += u64(number_array[column][digit_index])
			}

			// fmt.println(number)
			result = operation(result, number)
		}

		total += result
	}

	fmt.println(total)
}
