package p1

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

part1 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	data_string := strings.clone_from_bytes(data)

	current_rotation: i64 = 50
	zero_count: u64 = 0

	for line in strings.split_lines_iterator(&data_string) {
		rotation := line[0]

		rotate_amount, ok := strconv.parse_i64(line[1:])

		if rotation == 'L' {
			current_rotation -= rotate_amount
		} else {
			current_rotation += rotate_amount
		}
		current_rotation %%= 100

		if current_rotation == 0 {
			zero_count += 1
		}
	}

	fmt.println(zero_count)
}
