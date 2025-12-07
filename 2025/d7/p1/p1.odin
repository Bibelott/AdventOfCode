package p1

import "core:bytes"
import "core:fmt"
import "core:os"

part1 :: proc() {
	data := #load("../input")
	// data, _ := os.read_entire_file_from_filename("../test")

	line_width := bytes.index(data, {'\n'})
	line_count := bytes.count(data, {'\n'})

	beam_array := make([]bool, line_width * line_count)

	row := 0
	splits := 0

	for line in bytes.split_iterator(&data, {'\n'}) {
		defer row += 1
		for space, i in line {
			if space == 'S' || (row > 0 && get_at_row_col(beam_array, line_width, row - 1, i)^) {
				if space == '^' {
					get_at_row_col(beam_array, line_width, row, i - 1)^ = true
					get_at_row_col(beam_array, line_width, row, i + 1)^ = true
					splits += 1
				} else {
					get_at_row_col(beam_array, line_width, row, i)^ = true
				}
			}
		}
	}

	fmt.println(splits)
}

get_at_row_col :: proc(array: []bool, line_width: int, row: int, col: int) -> ^bool {
	return &array[row * line_width + col]
}
