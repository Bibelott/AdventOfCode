package p1_cuda

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:time"

when ODIN_OS == .Linux do foreign import cudaSum {"libCudaTexture.a", "system:/opt/cuda/targets/x86_64-linux/lib/libcudart.so", "system:stdc++"}

foreign cudaSum {
	sumNeighbours :: proc "c" (outputData: [^]i8, inputData: [^]i8, dataWidth: i32, dataHeight: i32) ---
}

part1_cuda :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	total := 0

	grid_width := bytes.index_byte(data, '\n')
	grid_height := bytes.count(data, {'\n'})

	grid := make([]i8, grid_width * grid_height)
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

			if is_paper {
				grid[grid_index] = 1
			}
			grid_index += 1
		}
	}

	grid_len := grid_index

	result_grid := make([]i8, grid_len)

	sumNeighbours(raw_data(result_grid), raw_data(grid), i32(grid_width), i32(grid_height))

	// fmt.println(result_grid)

	for r in result_grid {
		total += int(r)
	}

	// // indices_to_remove: [dynamic]int
	// removed_roll := true
	//
	// for total == 0 || removed_roll {
	// 	removed_roll = false
	// 	// clear(&indices_to_remove)
	//
	// 	for i := 0; i < grid_len; i += 1 {
	// 		if !grid[i] {
	// 			continue
	// 		}
	//
	// 		row, column := row_col_from_index(grid_width, i)
	//
	// 		local_sum := 0
	//
	// 		for row_offset := -1; row_offset <= 1; row_offset += 1 {
	// 			for column_offset := -1; column_offset <= 1; column_offset += 1 {
	// 				row_to_check := row + row_offset
	// 				column_to_check := column + column_offset
	//
	// 				if row_to_check < 0 ||
	// 				   row_to_check >= grid_height ||
	// 				   column_to_check < 0 ||
	// 				   column_to_check >= grid_width {
	// 					continue
	// 				}
	//
	// 				j := index_from_row_col(grid_width, row + row_offset, column + column_offset)
	//
	// 				if grid[j] {
	// 					local_sum += 1
	// 				}
	// 			}
	// 		}
	//
	// 		if local_sum < 5 { 	// we're counting the middle, so it's 5 instead of 4
	// 			total += 1
	// 			grid[i] = false
	// 			removed_roll = true
	// 			// append(&indices_to_remove, i)
	// 			// fmt.println(row, column)
	// 		}
	// 	}
	// 	// for index in indices_to_remove {
	// 	// 	grid[index] = false
	// 	// }
	// }

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
