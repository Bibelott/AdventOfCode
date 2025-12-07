package p2

import "core:bytes"
import "core:fmt"
import "core:os"
import "core:slice"

part2 :: proc() {
	data, success := os.read_entire_file_from_filename("input")

	if !success {
		fmt.eprintln("Could not read file")
		return
	}

	joltage_sum := 0

	for battery_bank in bytes.split_iterator(&data, {'\n'}) {
		joltage := 0
		search_start_index := 0

		for i := 0; i < 12; i += 1 {
			digit_index, _ := slice.max_index(
				battery_bank[search_start_index:len(battery_bank) - (11 - i)],
			)
			digit_index += search_start_index

			search_start_index = digit_index + 1

			// fmt.print(rune(battery_bank[digit_index]))

			joltage += int(battery_bank[digit_index] - '0')
			joltage *= 10
		}
		// fmt.println()

		joltage_sum += joltage / 10
	}

	fmt.println(joltage_sum)
}
