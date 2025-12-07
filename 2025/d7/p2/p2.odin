package p2

import "core:bytes"
import "core:fmt"
import "core:os"

part2 :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("../test")

	line_width := bytes.index(data, {'\n'})
	line_count := bytes.count(data, {'\n'}) / 2

	beam_array := make([]u64, line_width * line_count) // all the possible ways for the beam to get to each space

	data_row := 0

	for line in bytes.split_iterator(&data, {'\n'}) {
		defer data_row += 1

		if data_row % 2 == 1 {
			continue
		}

		row := data_row / 2

		for space, i in line {
			if space == 'S' {
				get_at_row_col(beam_array, line_width, row, i)^ = 1
			}
			if row == 0 {
				continue
			}

			prev_splits := get_at_row_col(beam_array, line_width, row - 1, i)^
			if space == '^' {
				get_at_row_col(beam_array, line_width, row, i - 1)^ += prev_splits
				get_at_row_col(beam_array, line_width, row, i + 1)^ += prev_splits
			} else {
				get_at_row_col(beam_array, line_width, row, i)^ += prev_splits
			}
		}
	}

	// for space, i in beam_array {
	// 	if i % line_width == 0 {
	// 		fmt.println()
	// 	}
	// 	fmt.printf("%10d ", space)
	// }

	splits: u64 = 0

	for space in beam_array[(line_count - 1) * line_width:] { 	// Count all possibilities in the last line
		splits += space
	}

	fmt.println(splits)
}

get_at_row_col :: proc(array: []u64, line_width: int, row: int, col: int) -> ^u64 {
	return &array[row * line_width + col]
}
