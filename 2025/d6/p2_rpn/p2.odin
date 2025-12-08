package p2_rpn

import "core:bytes"
import "core:fmt"
import "core:os"

ROWS :: 5

part2_rpn :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("test")

	line_width := bytes.index(data, {'\n'})

	char_grid := make([][ROWS]byte, line_width) // column-major

	row := 0

	for line in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1

		if row == ROWS {
			break
		}

		for char, column in line {
			char_grid[column][row] = char
		}
	}

	// fmt.println(char_grid[:][:])

	stack: [dynamic]u64

	total: u64 = 0

	column_loop: #reverse for column in char_grid {
		number: u64 = 0

		for char in column {
			if char == ' ' {
				continue
			}

			if char == '+' || char == '*' {
				operation := char == '+' ? stack_add : stack_mul

				// fmt.println(number)
				append(&stack, number)
				total += operation(&stack)
				// fmt.println("+")
				// fmt.println(total)
				continue column_loop
			}

			number *= 10
			number += u64(char - '0')
		}
		// fmt.println(number)
		if number != 0 {
			append(&stack, number)
		}
	}

	fmt.println(total)
}

stack_add :: proc(stack: ^[dynamic]u64) -> (sum: u64) {
	for len(stack) > 0 {
		sum += pop(stack)
	}
	return
}

stack_mul :: proc(stack: ^[dynamic]u64) -> (product: u64) {
	product = 1
	for len(stack) > 0 {
		product *= pop(stack)
	}
	return
}
