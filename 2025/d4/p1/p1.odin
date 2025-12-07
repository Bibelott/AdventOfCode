package p1

import "core:bytes"
import "core:fmt"
import "core:os"

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	total := 0

	grid_width := bytes.index_byte(data, '\n')
	grid_height := bytes.count(data, {'\n'})

	grid := make([]bool, grid_width * grid_height)
	defer delete(grid)

	grid_index := 0

	for str_row in bytes.split_iterator(&data, {'\n'}) {
		for char in str_row {
			is_paper: bool

			if char == '@' {
				is_paper = true
			} else if char == '.' {
				is_paper = false
			} else {
				continue
			}

			grid[grid_index] = is_paper
			grid_index += 1
		}
	}

	grid_len := grid_index

	for i := 0; i < grid_len; i += 1 {
		if !grid[i] {
			continue
		}

		row, column := row_col_from_index(grid_width, i)

		local_sum := 0

		for row_offset := -1; row_offset <= 1; row_offset += 1 {
			for column_offset := -1; column_offset <= 1; column_offset += 1 {
				row_to_check := row + row_offset
				column_to_check := column + column_offset

				if row_to_check < 0 ||
				   row_to_check >= grid_height ||
				   column_to_check < 0 ||
				   column_to_check >= grid_width {
					continue
				}

				j := index_from_row_col(grid_width, row + row_offset, column + column_offset)

				if grid[j] {
					local_sum += 1
				}
			}
		}

		if local_sum < 5 { 	// we're counting the middle, so it's 5 instead of 4
			total += 1
			// fmt.println(row, column)
		}
	}

	fmt.println(total)
}

index_from_row_col :: #force_inline proc(grid_width: int, row: int, column: int) -> int {
	return row * grid_width + column
}

row_col_from_index :: #force_inline proc(grid_width: int, index: int) -> (row: int, column: int) {
	row = index / grid_width
	column = index % grid_width
	return
}
