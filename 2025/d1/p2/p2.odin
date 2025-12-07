package p2

import "core://fmt"
import "core:os"
import "core:strconv"
import "core:strings"

part2 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	data_string := strings.clone_from_bytes(data)

	current_rotation: i64 = 50
	zero_count: i64 = 0

	for line in strings.split_lines_iterator(&data_string) {
		rotation := line[0]

		rotate_amount, ok := strconv.parse_i64(line[1:])

		//fmt.print(current_rotation, "")

		last_rotation := current_rotation

		if rotation == 'L' {
			current_rotation -= rotate_amount

			//fmt.println("-", rotate_amount, "->", current_rotation %% 100)

			if current_rotation <= 0 {
				passed_zero_amount :=
					(rotate_amount - last_rotation) / 100 + (1 if last_rotation != 0 else 0)
				zero_count += passed_zero_amount
				//fmt.println("Passed zero", passed_zero_amount, "times")
				//fmt.println("Total:", zero_count)
			}
		} else {
			current_rotation += rotate_amount

			//fmt.println("+", rotate_amount, "->", current_rotation %% 100)

			if current_rotation >= 100 {
				passed_zero_amount := (rotate_amount - 100 + last_rotation) / 100 + 1
				zero_count += passed_zero_amount
				//fmt.println("Passed zero", passed_zero_amount, "times")
				//fmt.println("Total:", zero_count)
			}
		}
		//fmt.println()
		current_rotation %%= 100
	}

	fmt.println(zero_count)
}
